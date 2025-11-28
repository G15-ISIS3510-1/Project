import 'package:flutter/foundation.dart';

import '../../app/utils/net.dart';
import '../../app/utils/result.dart';
import '../repositories/booking_repository.dart';
import '../sources/local/booking_local_source.dart';
import '../sources/remote/analytics_remote_source.dart';
import '../stores/fees_taxes_store.dart';

class FeesTaxesResult {
  final double average;
  final int sampleSize;
  final String source; // remote | bookings-remote | local-db | cache
  final bool usedCache;
  final DateTime fetchedAt;

  FeesTaxesResult({
    required this.average,
    required this.sampleSize,
    required this.source,
    required this.usedCache,
    required this.fetchedAt,
  });
}

abstract class FeesTaxesRepository {
  Future<FeesTaxesResult> getAverageFeesTaxes({
    required String userId,
    required bool asHost,
    bool forceRefresh = false,
  });
}

class FeesTaxesRepositoryImpl implements FeesTaxesRepository {
  final AnalyticsRemoteSource remote;
  final BookingsRepository bookingsRepo;
  final BookingLocalSource bookingLocal;
  final FeesTaxesStore store;

  FeesTaxesRepositoryImpl({
    required this.remote,
    required this.bookingsRepo,
    required this.bookingLocal,
    required this.store,
  });

  static const _cacheTtl = Duration(hours: 12);

  @override
  Future<FeesTaxesResult> getAverageFeesTaxes({
    required String userId,
    required bool asHost,
    bool forceRefresh = false,
  }) async {
    // Si no hay sesión, devolvemos ceros para evitar errores de canal aislado al cerrar DB.
    if (userId.isEmpty) {
      return FeesTaxesResult(
        average: 0,
        sampleSize: 0,
        source: 'no-user',
        usedCache: true,
        fetchedAt: DateTime.now().toUtc(),
      );
    }

    // 1) Fresh cache (if allowed)
    if (!forceRefresh) {
      try {
        final cached = await store.load(
          userId: userId,
          asHost: asHost,
          ttl: _cacheTtl,
        );
        if (cached != null) {
          return FeesTaxesResult(
            average: cached.average,
            sampleSize: cached.sampleSize,
            source: 'cache',
            usedCache: true,
            fetchedAt: cached.savedAt,
          );
        }
      } catch (_) {
        // ignore cache load errors (e.g., isolate closed)
      }
    }

    final isOnline = await Net.isOnline();

    // 2) Try dedicated analytics endpoint (online)
    if (isOnline) {
      final remoteRes = await _tryRemoteEndpoint();
      if (remoteRes != null) {
        try {
          await store.save(
            userId: userId,
            asHost: asHost,
            average: remoteRes.average,
            sampleSize: remoteRes.sampleSize,
          );
        } catch (_) {}
        return FeesTaxesResult(
          average: remoteRes.average,
          sampleSize: remoteRes.sampleSize,
          source: 'remote',
          usedCache: false,
          fetchedAt: DateTime.now().toUtc(),
        );
      }
    }

    // 3) Try to aggregate from remote bookings (bookingsRepo handles cache/offline)
    if (isOnline) {
      final bookingsAggregation =
          await _aggregateFromBookingsRepository(asHost: asHost);
      if (bookingsAggregation != null) {
        try {
          await store.save(
            userId: userId,
            asHost: asHost,
            average: bookingsAggregation.average,
            sampleSize: bookingsAggregation.sampleSize,
          );
        } catch (_) {}
        return FeesTaxesResult(
          average: bookingsAggregation.average,
          sampleSize: bookingsAggregation.sampleSize,
          source: 'bookings-remote',
          usedCache: false,
          fetchedAt: DateTime.now().toUtc(),
        );
      }
    }

    // 4) Local DB aggregation (offline fallback)
    final localAggregation = await _aggregateFromLocalDb(
      userId: userId,
      asHost: asHost,
    );
    if (localAggregation != null) {
      try {
        await store.save(
          userId: userId,
          asHost: asHost,
          average: localAggregation.average,
          sampleSize: localAggregation.sampleSize,
        );
      } catch (_) {}
      return FeesTaxesResult(
        average: localAggregation.average,
        sampleSize: localAggregation.sampleSize,
        source: 'local-db',
        usedCache: true,
        fetchedAt: DateTime.now().toUtc(),
      );
    }

    // 5) Last-resort stale cache
    try {
      final stale = await store.load(
        userId: userId,
        asHost: asHost,
        ttl: null,
      );
      if (stale != null) {
        return FeesTaxesResult(
          average: stale.average,
          sampleSize: stale.sampleSize,
          source: 'stale-cache',
          usedCache: true,
          fetchedAt: stale.savedAt,
        );
      }
    } catch (_) {}

    // If there's no data at all, return zeros gracefully.
    return FeesTaxesResult(
      average: 0,
      sampleSize: 0,
      source: 'empty',
      usedCache: true,
      fetchedAt: DateTime.now().toUtc(),
    );
  }

  Future<_Aggregated?> _tryRemoteEndpoint() async {
    try {
      final response = await remote.getFeesTaxesAverage();
      final avg = (response['average'] ?? response['avg']) as num?;
      final count = (response['sample_size'] ??
              response['count'] ??
              response['bookings'] ??
              0) as num;
      if (avg == null) return null;
      return _Aggregated(
        average: avg.toDouble(),
        sampleSize: count.toInt(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FeesTaxesRepository] remote endpoint failed: $e');
      }
      return null;
    }
  }

  Future<_Aggregated?> _aggregateFromBookingsRepository({
    required bool asHost,
  }) async {
    try {
      const pageSize = 100;
      int skip = 0;
      bool hasMore = true;
      double sum = 0.0;
      int count = 0;
      int guard = 0; // avoid infinite loops

      while (hasMore && guard < 8) {
        final res = await bookingsRepo.listMyBookings(
          skip: skip,
          limit: pageSize,
          statusFilter: null,
          asHost: asHost,
        );

        await res.when(
          ok: (page) async {
            for (final b in page.items) {
              sum += (b.fees) + (b.taxes);
              count++;
            }
            hasMore = page.hasMore && page.items.length == pageSize;
            skip += pageSize;
          },
          err: (msg) async {
            hasMore = false;
          },
        );

        if (!hasMore) break;
        guard++;
      }

      if (count == 0) return null;
      return _Aggregated(average: sum / count, sampleSize: count);
    } catch (e) {
      // Avoid crashing if the Drift isolate was closed (e.g., logout).
      if (kDebugMode && !_isolateClosed(e)) {
        debugPrint('[FeesTaxesRepository] bookings aggregation failed: $e');
      }
      return null;
    }
  }

  Future<_Aggregated?> _aggregateFromLocalDb({
    required String userId,
    required bool asHost,
  }) async {
    try {
      const pageSize = 200;
      int skip = 0;
      double sum = 0.0;
      int count = 0;

      while (true) {
        final page = await bookingLocal.getPageMine(
          userId: userId,
          asHost: asHost,
          skip: skip,
          limit: pageSize,
          status: null,
        );
        if (page.isEmpty) break;
        for (final b in page) {
          sum += (b.fees) + (b.taxes);
          count++;
        }
        if (page.length < pageSize) break;
        skip += pageSize;
      }

      if (count == 0) return null;
      return _Aggregated(average: sum / count, sampleSize: count);
    } catch (e) {
      if (kDebugMode && !_isolateClosed(e)) {
        debugPrint('[FeesTaxesRepository] local aggregation failed: $e');
      }
      return null;
    }
  }

  bool _isolateClosed(Object e) {
    final msg = e.toString();
    return msg.contains('connection was closed') ||
        msg.contains('isolate channel') ||
        msg.contains('Bad state');
  }
}

class _Aggregated {
  final double average;
  final int sampleSize;
  _Aggregated({required this.average, required this.sampleSize});
}

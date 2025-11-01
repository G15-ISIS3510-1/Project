// lib/data/repositories/booking_repository_cached.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/utils/result.dart';
import 'package:flutter_app/app/utils/pagination.dart';
import 'package:flutter_app/data/models/booking_model.dart' as vm;
import 'package:flutter_app/data/models/booking_status.dart' as vms;
import 'package:flutter_app/data/models/booking_create_model.dart' as vmc;
import 'package:flutter_app/data/repositories/booking_repository.dart';
import 'package:flutter_app/data/sources/local/booking_local_source.dart';

class BookingsRepositoryCached implements BookingsRepository {
  final BookingsRepositoryImpl remote;
  final BookingLocalSource local;

  /// identidad en tiempo real
  final String Function() currentUserId;
  final bool Function() isHost;

  BookingsRepositoryCached({
    required this.remote,
    required this.local,
    required this.currentUserId,
    required this.isHost,
  });

  void clearCache() {
    try {
      remote.clearCache();
    } catch (_) {}
    if (kDebugMode) debugPrint('[BookingsRepoCached] clearCache()');
  }

  @override
  Future<Result<BookingsPage>> listMyBookings({
    int skip = 0,
    int limit = 20,
    vms.BookingStatus? statusFilter,
    bool asHost = false, // para cumplir interfaz, pero usaremos el real
  }) async {
    final uid = currentUserId();
    final host = isHost();
    final statusStr = statusFilter?.asParam;

    if (kDebugMode) {
      debugPrint(
        '[BookingsRepoCached] listMyBookings uid=$uid host=$host skip=$skip limit=$limit status=$statusStr',
      );
    }

    // 🚫 no pegues a red si aún no hay sesión
    if (uid.isEmpty) {
      if (kDebugMode)
        debugPrint(
          '[BookingsRepoCached] uid empty → NO REMOTE; return empty + no-more',
        );
      return Result.ok(BookingsPage(items: const [], hasMore: false));
    }

    // 🔵 remoto-first (evita stale cross-user)
    final res = await remote.listMyBookings(
      skip: skip,
      limit: limit,
      statusFilter: statusFilter,
      asHost: host,
    );

    return res.when(
      ok: (page) async {
        if (kDebugMode)
          debugPrint(
            '[BookingsRepoCached] REMOTE OK items=${page.items.length} hasMore=${page.hasMore}',
          );
        await local.cacheModels(page.items);
        await local.checkpoint(
          lastFetchAt: DateTime.now().toUtc(),
          cursor: page.hasMore ? '${skip + limit}' : null,
          scope:
              'bookings:$uid:${host ? 'host' : 'renter'}', // ← scope por identidad
        );
        return Result.ok(page);
      },
      err: (msg) async {
        if (kDebugMode)
          debugPrint(
            '[BookingsRepoCached] REMOTE ERR="$msg" → fallback local.getPageMine',
          );
        final cached = await local.getPageMine(
          userId: uid,
          asHost: host,
          skip: skip,
          limit: limit,
          status: statusStr,
        );
        if (cached.isNotEmpty) {
          final hasMore = cached.length == limit;
          return Result.ok(BookingsPage(items: cached, hasMore: hasMore));
        }
        return Result.err(msg);
      },
    );
  }

  @override
  Future<Result<vm.Booking>> createBooking(vmc.BookingCreateModel data) async {
    final res = await remote.createBooking(data);
    return res.when(
      ok: (b) async {
        await local.cacheModels([b]);
        return Result.ok(b);
      },
      err: (m) => Result.err(m),
    );
  }
}

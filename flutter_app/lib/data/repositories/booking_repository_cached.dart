import 'package:flutter_app/app/utils/result.dart';
import 'package:flutter_app/data/models/booking_model.dart' as vm;
import 'package:flutter_app/data/models/booking_status.dart' as vms;
import 'package:flutter_app/data/models/booking_create_model.dart' as vmc;

import 'package:flutter_app/app/utils/pagination.dart';
import 'package:flutter_app/data/repositories/booking_repository.dart';
import 'package:flutter_app/data/sources/local/booking_local_source.dart';

class BookingsRepositoryCached implements BookingsRepository {
  final BookingsRepositoryImpl remote; // your real repo
  final BookingLocalSource local;

  BookingsRepositoryCached({required this.remote, required this.local});
  void clearCache() {
    try {
      remote.clearCache();
    } catch (_) {}
  }

  @override
  Future<Result<BookingsPage>> listMyBookings({
    int skip = 0,
    int limit = 20,
    vms.BookingStatus? statusFilter,
  }) async {
    try {
      // 1) Fast path desde cache para primera página y sin forceRefresh flag
      if (skip == 0) {
        final cached = await local.getPage(
          skip: skip,
          limit: limit,
          status: statusFilter?.asParam,
        );
        if (cached.isNotEmpty) {
          final hasMore = cached.length == limit; // heurística
          return Result.ok(BookingsPage(items: cached, hasMore: hasMore));
        }
      }

      // 2) Red (delegado 1:1)
      final res = await remote.listMyBookings(
        skip: skip,
        limit: limit,
        statusFilter: statusFilter,
      );

      // 3) Si ok -> cache; si err -> fallback cache
      return res.when(
        ok: (page) async {
          await local.cacheModels(page.items);
          await local.checkpoint(
            lastFetchAt: DateTime.now().toUtc(),
            cursor: page.hasMore ? '${skip + limit}' : null,
          );
          return Result.ok(page);
        },
        err: (msg) async {
          // Fallback cache
          final cached = await local.getPage(
            skip: skip,
            limit: limit,
            status: statusFilter?.asParam,
          );
          if (cached.isNotEmpty) {
            final hasMore = cached.length == limit;
            return Result.ok(BookingsPage(items: cached, hasMore: hasMore));
          }
          return Result.err(msg);
        },
      );
    } catch (e) {
      // Excepción dura: intenta cache
      final cached = await local.getPage(
        skip: skip,
        limit: limit,
        status: statusFilter?.asParam,
      );
      if (cached.isNotEmpty) {
        final hasMore = cached.length == limit;
        return Result.ok(BookingsPage(items: cached, hasMore: hasMore));
      }
      return Result.err('No se pudieron cargar las reservas: $e');
    }
  }

  @override
  Future<Result<vm.Booking>> createBooking(vmc.BookingCreateModel data) async {
    // No cambiamos semántica del remoto. Cacheamos si llega OK.
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

// lib/domain/trips/bookings_repository.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/utils/pagination.dart';
import 'package:flutter_app/app/utils/result.dart';
import 'package:flutter_app/data/models/booking_model.dart';
import 'package:flutter_app/data/models/booking_status.dart';
import 'package:flutter_app/data/models/booking_create_model.dart';
import 'package:flutter_app/data/sources/remote/api_client.dart';
import 'package:flutter_app/data/sources/remote/booking_remote_source.dart'; // BookingService

// NEW: LRU cache
import 'package:flutter_app/app/utils/lru_cache.dart';

class BookingsPage {
  final List<Booking> items;
  final bool hasMore;
  BookingsPage({required this.items, required this.hasMore});
}

abstract class BookingsRepository {
  Future<Result<BookingsPage>> listMyBookings({
    int skip,
    int limit,
    BookingStatus? statusFilter,
    bool asHost,
  });

  Future<Result<Booking>> createBooking(BookingCreateModel data);
}

class BookingsRepositoryImpl implements BookingsRepository {
  final BookingService remote;

  // NEW: Keep the N most-recent 100-booking chunks (LRU by (skip,limit,status))
  // TripsViewModel calls with limit=100; capacity 3 ~= 300 bookings in memory.
  final LruCache<String, BookingsPage> _cache = LruCache<String, BookingsPage>(
    3,
  );

  BookingsRepositoryImpl(this.remote);

  final Map<String, BookingsPage> _mem = {};
  void clearCache() {
    _mem.clear();
    if (kDebugMode) debugPrint('[BookingsRepoImpl] clearCache()');
  }

  String _key({
    required String token,
    required bool asHost,
    required int skip,
    required int limit,
    String? status,
  }) =>
      't:${token.isEmpty ? "none" : token.hashCode}'
      '|h:${asHost ? 1 : 0}'
      '|s:$skip|l:$limit|st:${status ?? ""}';

  @override
  Future<Result<BookingsPage>> listMyBookings({
    int skip = 0,
    int limit = 20,
    BookingStatus? statusFilter,
    bool asHost = false, // ← importante que exista y se propague
  }) async {
    final token = Api.I().token ?? '';
    final k = _key(
      token: token,
      asHost: asHost,
      skip: skip,
      limit: limit,
      status: statusFilter?.asParam,
    );

    // (Opcional) lee cache mem per-key
    final cached = _mem[k];
    if (cached != null) {
      if (kDebugMode)
        debugPrint(
          '[BookingsRepoImpl] mem-hit $k items=${cached.items.length}',
        );
      return Result.ok(cached);
    }

    final resp = await remote.listMyBookings(
      skip: skip,
      limit: limit,
      statusFilter: statusFilter?.asParam,
      asHost: asHost,
    );

    if (resp.statusCode != 200) {
      return Result.err('HTTP ${resp.statusCode}');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final items = (json['items'] as List)
        .map((m) => Booking.fromJson(m as Map<String, dynamic>))
        .toList();
    final hasMore = json['has_more'] == true || items.length == limit;

    final page = BookingsPage(items: items, hasMore: hasMore);
    _mem[k] = page;
    if (kDebugMode)
      debugPrint(
        '[BookingsRepoImpl] net-ok $k items=${items.length} hasMore=$hasMore',
      );
    return Result.ok(page);
  }

  @override
  Future<Result<Booking>> createBooking(BookingCreateModel data) async {
    try {
      final res = await remote.create(data.toJson());
      if (res.statusCode != 201 && res.statusCode != 200) {
        // intenta sacar "detail" del body
        String detail = 'Error al crear la reserva';
        try {
          final body = jsonDecode(res.body);
          detail = (body['detail'] ?? body['message'] ?? res.body).toString();
        } catch (_) {
          if (res.body.isNotEmpty) detail = res.body;
        }
        return Result.err('Error ${res.statusCode}: $detail');
      }
      // On successful creation we should invalidate cache so lists refresh
      _cache.clear();

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        return Result.err('Respuesta inesperada al crear la reserva.');
      }
      final booking = _mapBooking(decoded);
      return Result.ok(booking);
    } catch (e) {
      return Result.err('Error de red/conexión: $e');
    }
  }

  // ---------- mapping ----------
  Booking _mapBooking(Map<String, dynamic> j) {
    DateTime _parse(Object? v) => DateTime.parse(v.toString()).toLocal();
    return Booking(
      bookingId: j['booking_id']?.toString() ?? j['id']?.toString() ?? '',
      vehicleId: j['vehicle_id']?.toString() ?? '',
      renterId: j['renter_id']?.toString() ?? '',
      hostId: j['host_id']?.toString() ?? '',
      startTs: _parse(j['start_ts'] ?? j['start_date'] ?? j['start']),
      endTs: _parse(j['end_ts'] ?? j['end_date'] ?? j['end']),
      status: BookingStatus.fromString(j['status']?.toString()),
      dailyPriceSnapshot: (j['daily_price_snapshot'] as num).toDouble(),
      insuranceDailyCostSnapshot: (j['insurance_daily_cost_snapshot'] as num?)
          ?.toDouble(),
      subtotal: (j['subtotal'] as num).toDouble(),
      fees: (j['fees'] as num?)?.toDouble() ?? 0,
      taxes: (j['taxes'] as num?)?.toDouble() ?? 0,
      total: (j['total'] as num).toDouble(),
      currency: j['currency']?.toString() ?? 'USD',
      odoStart: (j['odo_start'] as num?)?.toInt(),
      odoEnd: (j['odo_end'] as num?)?.toInt(),
      fuelStart: (j['fuel_start'] as num?)?.toInt(),
      fuelEnd: (j['fuel_end'] as num?)?.toInt(),
      createdAt: _parse(j['created_at']),
    );
  }
}

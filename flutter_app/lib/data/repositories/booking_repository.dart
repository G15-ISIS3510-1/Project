// lib/domain/trips/bookings_repository.dart

import 'dart:convert';
import 'package:flutter_app/app/utils/pagination.dart';
import 'package:flutter_app/app/utils/result.dart';
import 'package:flutter_app/data/models/booking_model.dart';
import 'package:flutter_app/data/models/booking_status.dart';
import 'package:flutter_app/data/models/booking_create_model.dart';
import 'package:flutter_app/data/sources/remote/booking_remote_source.dart'; // BookingService

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
  });

  Future<Result<Booking>> createBooking(BookingCreateModel data);
}

class BookingsRepositoryImpl implements BookingsRepository {
  final BookingService remote;
  BookingsRepositoryImpl(this.remote);

  @override
  Future<Result<BookingsPage>> listMyBookings({
    int skip = 0,
    int limit = 20,
    BookingStatus? statusFilter,
  }) async {
    try {
      final res = await remote.listMyBookings(
        skip: skip,
        limit: limit,
        statusFilter: statusFilter?.asParam,
      );
      if (res.statusCode != 200) {
        return Result.err('Bookings ${res.statusCode}: ${res.body}');
      }

      final page = parsePaginated<Map<String, dynamic>>(
        res.body,
        (m) => m, // primero en bruto, luego mapeamos a Booking
      );

      final items = page.items.map(_mapBooking).toList(growable: false);
      return Result.ok(BookingsPage(items: items, hasMore: page.hasMore));
    } catch (e) {
      return Result.err('No se pudieron cargar las reservas: $e');
    }
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

// lib/domain/trips/trips_repository.dart

import 'package:flutter_app/app/utils/result.dart';
import 'package:flutter_app/data/models/booking_model.dart';
import 'package:flutter_app/data/models/booking_status.dart';
import 'package:flutter_app/data/sources/remote/booking_remote_source.dart';
import 'package:flutter_app/presentation/common_widgets/trip_filter.dart';

class BookingsPage {
  final List<Booking> items;
  final bool
  hasMore; // tu backend actual no devuelve has_more en list, así que lo derivamos
  BookingsPage({required this.items, required this.hasMore});
}

abstract class BookingsRepository {
  Future<Result<BookingsPage>> listMyBookings({
    int skip,
    int limit,
    BookingStatus? statusFilter, // sólo usado para cancelled/confirmed/etc.
  });
}

class BookingsRepositoryImpl implements BookingsRepository {
  final BookingsRemoteSource remote;
  BookingsRepositoryImpl(this.remote);

  @override
  Future<Result<BookingsPage>> listMyBookings({
    int skip = 0,
    int limit = 20,
    BookingStatus? statusFilter,
  }) async {
    try {
      final list = await remote.listMyBookings(
        skip: skip,
        limit: limit,
        statusFilter: statusFilter?.asParam,
      );

      final items = list.map(_mapBooking).toList();
      // Como el endpoint devuelve lista directa, inferimos hasMore comparando tamaño con "limit"
      final hasMore = items.length == limit;

      return Result.ok(BookingsPage(items: items, hasMore: hasMore));
    } catch (e) {
      return Result.err('No se pudieron cargar las reservas: $e');
    }
  }

  Booking _mapBooking(Map<String, dynamic> j) {
    DateTime _parse(Object? v) => DateTime.parse(v.toString()).toLocal();

    return Booking(
      bookingId: j['booking_id']?.toString() ?? '',
      vehicleId: j['vehicle_id']?.toString() ?? '',
      renterId: j['renter_id']?.toString() ?? '',
      hostId: j['host_id']?.toString() ?? '',
      startTs: _parse(j['start_ts']),
      endTs: _parse(j['end_ts']),
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

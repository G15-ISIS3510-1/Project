import 'booking_status.dart';

class Booking {
  final String bookingId;
  final String vehicleId;
  final String renterId;
  final String hostId;

  final DateTime startTs;
  final DateTime endTs;
  final BookingStatus status;

  // snapshots económicos
  final double dailyPriceSnapshot;
  final double? insuranceDailyCostSnapshot;
  final double subtotal;
  final double fees;
  final double taxes;
  final double total;
  final String currency;

  // estado vehículo
  final int? odoStart;
  final int? odoEnd;
  final int? fuelStart;
  final int? fuelEnd;

  final DateTime createdAt;

  Booking({
    required this.bookingId,
    required this.vehicleId,
    required this.renterId,
    required this.hostId,
    required this.startTs,
    required this.endTs,
    required this.status,
    required this.dailyPriceSnapshot,
    required this.insuranceDailyCostSnapshot,
    required this.subtotal,
    required this.fees,
    required this.taxes,
    required this.total,
    required this.currency,
    required this.odoStart,
    required this.odoEnd,
    required this.fuelStart,
    required this.fuelEnd,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> j) {
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

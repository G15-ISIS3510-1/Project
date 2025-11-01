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
}

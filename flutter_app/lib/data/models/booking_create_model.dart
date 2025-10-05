import 'dart:convert';

class BookingCreateModel {
  final String vehicleId;
  final String renterId;
  final String hostId;
  final String insurancePlanId;
  final String startTs;
  final String endTs;
  final double dailyPriceSnapshot;
  final double insuranceDailyCostSnapshot;
  final double subtotal;
  final double fees;
  final double taxes;
  final double total;
  final String currency;

  BookingCreateModel({
    required this.vehicleId,
    required this.renterId,
    required this.hostId,
    required this.insurancePlanId,
    required this.startTs,
    required this.endTs,
    required this.dailyPriceSnapshot,
    required this.insuranceDailyCostSnapshot,
    required this.subtotal,
    required this.fees,
    required this.taxes,
    required this.total,
    this.currency = 'USD',
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'renter_id': renterId,
      'host_id': hostId,
      'insurance_plan_id': insurancePlanId,
      'start_ts': startTs,
      'end_ts': endTs,
      'daily_price_snapshot': dailyPriceSnapshot,
      'insurance_daily_cost_snapshot': insuranceDailyCostSnapshot,
      'subtotal': subtotal,
      'fees': fees,
      'taxes': taxes,
      'total': total,
      'currency': currency,
    };
  }
}
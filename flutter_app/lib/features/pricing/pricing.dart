// lib/features/pricing/pricing.dart
class Pricing {
  final String pricing_id;
  final String vehicleId;
  final double dailyPrice;
  final int minDays;
  final int maxDays;
  final String currency;

  Pricing({
    required this.pricing_id,
    required this.vehicleId,
    required this.dailyPrice,
    required this.minDays,
    required this.maxDays,
    required this.currency,
  });

  factory Pricing.fromJson(Map<String, dynamic> j) => Pricing(
    pricing_id: j['pricing_id'].toString(),
    vehicleId: j['vehicle_id'].toString(),
    dailyPrice: (j['daily_price'] as num).toDouble(),
    minDays: (j['min_days'] as num).toInt(),
    maxDays: (j['max_days'] as num).toInt(),
    currency: j['currency'] as String,
  );

  Map<String, dynamic> toJson() => {
    'pricing_id': pricing_id,
    'vehicle_id': vehicleId,
    'daily_price': dailyPrice,
    'min_days': minDays,
    'max_days': maxDays,
    'currency': currency,
  };
}

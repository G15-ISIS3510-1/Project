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

  factory Pricing.fromJson(Map<String, dynamic> j) {
    num? _num(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      if (v is String) return num.tryParse(v);
      return null;
    }

    int _int(dynamic v, int def) => (_num(v)?.toInt()) ?? def;
    double _dbl(dynamic v, double d) => (_num(v)?.toDouble()) ?? d;

    return Pricing(
      pricing_id: (j['pricing_id'] ?? '').toString(),
      vehicleId: (j['vehicle_id'] ?? '').toString(),
      dailyPrice: _dbl(j['daily_price'], 0.0), // <- si falta, 0.0
      minDays: _int(j['min_days'], 1), // <- si falta, 1
      maxDays: _int(j['max_days'], 30), // <- si falta, 30
      currency: (j['currency'] as String?) ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() => {
    'pricing_id': pricing_id,
    'vehicle_id': vehicleId,
    'daily_price': dailyPrice,
    'min_days': minDays,
    'max_days': maxDays,
    'currency': currency,
  };
}

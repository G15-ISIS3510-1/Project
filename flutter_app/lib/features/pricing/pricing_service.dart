import 'dart:convert';
import 'package:http/http.dart';

import '../../core/api.dart';
import 'pricing.dart';

class PricingService {
  // Ej: GET /api/pricing?vehicle_id=123 -> { ... }
  static Future<Pricing?> getByVehicle(String vehicleId) async {
    final res = await Api.get('/api/pricing/vehicle/$vehicleId');
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw Exception('Pricing ${res.statusCode}: ${res.body}');
    }
    return Pricing.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<Pricing> create(
    String vehicleId,
    double pricePerDay, {
    String currency = 'USD',
  }) async {
    final body = {
      'vehicle_id': vehicleId,
      'price_per_day': pricePerDay,
      'currency': currency,
    };
    final res = await Api.post('/api/pricing/', body);
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Create pricing ${res.statusCode}: ${res.body}');
    }
    return Pricing.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}

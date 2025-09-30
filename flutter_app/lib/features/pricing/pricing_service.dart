import 'dart:convert';
import '../../core/api.dart';
import 'pricing.dart';

class PricingService {
  // Ej: GET /api/pricing?vehicle_id=123 -> { ... }
  static Future<Pricing?> getByVehicle(String vehicleId) async {
    final res = await Api.get('/api/pricing/vehicle?vehicle_id=$vehicleId');
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw Exception('Pricing ${res.statusCode}: ${res.body}');
    }
    return Pricing.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}

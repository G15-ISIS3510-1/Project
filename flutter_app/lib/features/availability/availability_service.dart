// lib/features/availability/availability_service.dart
import 'dart:convert';
import '../../core/api.dart';
import 'availability.dart';

class AvailabilityService {
  // Ej: GET /api/availability?vehicle_id=123 -> [ {...}, {...} ]
  static Future<List<AvailabilityWindow>> getByVehicle(String vehicleId) async {
    final res = await Api.get(
      '/api/vehicle-availability/vehicle?vehicle_id=$vehicleId',
    );
    if (res.statusCode == 404) return [];
    if (res.statusCode != 200) {
      throw Exception('Availability ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => AvailabilityWindow.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

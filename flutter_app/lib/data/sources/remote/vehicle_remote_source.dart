// lib/features/vehicles/vehicle_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/vehicle_model.dart';

// Asegúrate de tener una forma de obtener baseUrl y token.
// Si ya existen variables globales o un singleton, reúsalo.
class VehicleService {
  static String baseUrl =
      const String.fromEnvironment(
        'API_BASE',
        defaultValue: 'http://10.0.2.2:8000',
      ) +
      '/api';
  static String? token;

  static void configure({required String baseUrl_, required String token_}) {
    baseUrl = _normalizeBase(baseUrl_);
    token = token_;
  }

  static String _normalizeBase(String url) {
    // Remove trailing slash to avoid 307 redirects that can drop Authorization
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static Map<String, String> get _headers => {
    if (token != null) 'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  static Future<List<Vehicle>> list() async {
    final res = await http.get(
      Uri.parse('$baseUrl/vehicles/'),
      headers: _headers,
    );

    if (res.statusCode == 401) {
      throw Exception('Unauthorized: missing/invalid token for GET /vehicles');
    }
    if (res.statusCode != 200) {
      throw Exception('Vehicles list ${res.statusCode}: ${res.body}');
    }

    final data = json.decode(res.body) as List;
    return data
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 👇 NUEVO
  static Future<String> createVehicle({
    required String title,
    required String make,
    required String model,
    required int year,
    required String transmission, // 'AT' | 'MT'
    required double pricePerDay,
    required String plate,
    required int seats,
    required String fuelType, // 'gasoline'|'diesel'|'hybrid'|'electric'
    required int mileage,
    required String status, // 'available'|'unavailable' ...
    required double lat,
    required double lng,
    String? imageUrl,
  }) async {
    final uri = Uri.parse('$baseUrl/vehicles/'); // ajusta si es otro path
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // 👇 snake_case para FastAPI/Pydantic
    final body = {
      'title': title,
      'make': make,
      'model': model,
      'year': year,
      'transmission': transmission, // OK
      'plate': plate,
      'seats': seats,
      'fuel_type': fuelType, // 👈 requerido
      'mileage': mileage,
      'status': status,
      'lat': lat,
      'lng': lng,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
    };

    final res = await http.post(uri, headers: headers, body: jsonEncode(body));
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Create vehicle ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map && decoded['vehicle_id'] is String) {
      return decoded['vehicle_id'] as String;
    }
    // If your backend returns the whole object under a different key, adapt here.
    throw Exception(
      'Vehicle created but vehicle_id missing in response: ${res.body}',
    );
  }

  static Future<Vehicle> getById(String vehicleId) async {
    final uri = Uri.parse('$baseUrl/vehicles/$vehicleId');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Get vehicle ${res.statusCode}: ${res.body}');
    }

    final decoded = json.decode(res.body);

    if (decoded is List && decoded.isNotEmpty) {
      // array con un elemento
      final Map<String, dynamic> obj = decoded.first as Map<String, dynamic>;
      return Vehicle.fromJson(obj);
    } else if (decoded is Map<String, dynamic>) {
      // objeto directo
      return Vehicle.fromJson(decoded);
    } else {
      throw Exception('Unexpected vehicle payload');
    }
  }
}

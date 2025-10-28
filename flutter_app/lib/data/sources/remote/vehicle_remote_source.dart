// lib/data/sources/remote/vehicle_remote_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart'; // Api.I()

class VehicleService {
  /// GET /api/vehicles/?skip=&limit=
  Future<http.Response> list({int skip = 0, int limit = 100}) {
    final q = '?skip=$skip&limit=$limit';
    return Api.I().get('/api/vehicles/$q');
  }

  /// POST /api/vehicles/ -> retorna el vehicle_id creado (String)
  Future<http.Response> createVehicle(Map<String, dynamic> body) {
    return Api.I().post('/api/vehicles/', body);
  }

  /// GET /api/vehicles/{id} -> Vehicle
  Future<http.Response> getById(String vehicleId) async {
    return Api.I().get('/api/vehicles/$vehicleId');
  }
}

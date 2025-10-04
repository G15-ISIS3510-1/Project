// import '../sources/remote/vehicle_remote_source.dart';

// abstract class VehicleRepository {
//   // TODO: define repository interface methods
// }

// class VehicleRepositoryImpl implements VehicleRepository {
//   final VehicleRemoteSource remote;
//   VehicleRepositoryImpl({required this.remote});
//   // TODO: implement methods using remote
// }

import 'dart:convert';

import 'package:flutter_app/data/models/vehicle_model.dart';
import 'package:flutter_app/data/sources/remote/vehicle_remote_source.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> list();
  Future<Vehicle> getById(String vehicleId);

  /// Crea vehículo y devuelve su `vehicle_id`.
  Future<String> createVehicle({
    required String title,
    required String make,
    required String model,
    required int year,
    required String transmission, // 'AT' | 'MT'
    required double pricePerDay,
    required String plate,
    required int seats,
    required String fuelType, // 'gas' | 'diesel' | 'hybrid' | 'ev'
    required int mileage,
    required String status, // 'active' | 'inactive' | ...
    required double lat,
    required double lng,
    String? imageUrl,
  });
}

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleService remote;
  VehicleRepositoryImpl({required this.remote});

  @override
  Future<List<Vehicle>> list() async {
    final res = await remote.list();

    if (res.statusCode == 401) {
      throw Exception('Unauthorized: missing/invalid token for GET /vehicles');
    }
    if (res.statusCode != 200) {
      throw Exception('Vehicles list ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body);
    if (data is! List) {
      throw Exception('Unexpected payload for vehicles list');
    }
    return data
        .cast<Map<String, dynamic>>()
        .map((j) => Vehicle.fromJson(j))
        .toList();
  }

  @override
  Future<Vehicle> getById(String vehicleId) async {
    final res = await remote.getById(vehicleId);

    if (res.statusCode != 200) {
      throw Exception('Get vehicle ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);

    if (decoded is List && decoded.isNotEmpty) {
      return Vehicle.fromJson(decoded.first as Map<String, dynamic>);
    }
    if (decoded is Map<String, dynamic>) {
      return Vehicle.fromJson(decoded);
    }
    throw Exception('Unexpected vehicle payload');
  }

  @override
  Future<String> createVehicle({
    required String title,
    required String make,
    required String model,
    required int year,
    required String transmission,
    required double pricePerDay,
    required String plate,
    required int seats,
    required String fuelType,
    required int mileage,
    required String status,
    required double lat,
    required double lng,
    String? imageUrl,
  }) async {
    // Snake_case para FastAPI/Pydantic
    final body = <String, dynamic>{
      'title': title,
      'make': make,
      'model': model,
      'year': year,
      'transmission': transmission,
      'plate': plate,
      'seats': seats,
      'fuel_type': fuelType,
      'mileage': mileage,
      'status': status,
      'lat': lat,
      'lng': lng,
      'price_per_day': pricePerDay, // si tu API lo acepta en create
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
    };

    final res = await remote.createVehicle(body);

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Create vehicle ${res.statusCode}: ${res.body}');
    }

    // Acepta múltiples formatos de respuesta
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      final id1 = decoded['vehicle_id'];
      if (id1 is String && id1.isNotEmpty) return id1;

      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final id2 = data['vehicle_id'];
        if (id2 is String && id2.isNotEmpty) return id2;
      }

      // objeto completo del vehículo
      try {
        final v = Vehicle.fromJson(decoded);
        if (v.vehicle_id.isNotEmpty) return v.vehicle_id;
      } catch (_) {}
    }

    throw Exception(
      'Vehicle created but vehicle_id missing in response: ${res.body}',
    );
  }
}

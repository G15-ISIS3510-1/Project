import 'dart:convert';
import 'package:flutter_app/app/utils/pagination.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/data/models/vehicle_model.dart';
import 'package:flutter_app/data/sources/remote/vehicle_remote_source.dart';

// Added to use compute for background parsing
import 'package:flutter/foundation.dart';

// NEW: LRU cache
import 'package:flutter_app/app/utils/lru_cache.dart';

abstract class VehicleRepository {
  /// Returns only the first page's items (kept for backwards compat).
  Future<List<Vehicle>> list();

  /// New: returns a paginated slice with metadata (skip/limit/hasMore).
  Future<Paginated<Vehicle>> listPaginated({int skip, int limit});

  Future<Vehicle> getById(String vehicleId);

  Future<String> uploadVehiclePhoto({required XFile file});

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

  // --- NEW: repo-level LRU page cache (key = skip of 100-chunk) ---
  // Keep the most recently used 3 chunks (≈ 300 vehicles) in memory.
  // Each chunk is exactly what your UI already asks: limit=100.
  final LruCache<int, Paginated<Vehicle>> _pageCache =
      LruCache<int, Paginated<Vehicle>>(3);

  VehicleRepositoryImpl({required this.remote});

  /// Clears the in-memory cache (call on pull-to-refresh or logout).
  void clearCache() => _pageCache.clear();

  @override
  Future<Paginated<Vehicle>> listPaginated({int skip = 0, int limit = 100}) async {
    // 1) Try cache first (LRU by [skip])
    final cached = _pageCache.get(skip);
    if (cached != null && (cached.limit == 0 || cached.limit == limit)) {
      return cached;
    }

    // 2) Otherwise hit network and cache the result
    final res = await remote.list(skip: skip, limit: limit);

    if (res.statusCode == 401) {
      throw Exception('Unauthorized: missing/invalid token for GET /vehicles');
    }
    if (res.statusCode != 200) {
      throw Exception('Vehicles list ${res.statusCode}: ${res.body}');
    }

    final page = parsePaginated<Vehicle>(res.body, (m) => Vehicle.fromJson(m));
    _pageCache.put(skip, page);
    return page;
  }

  @override
  Future<List<Vehicle>> list() async {
    final page = await listPaginated(skip: 0, limit: 100);
    return page.items; // keeps old behavior
  }

  @override
  Future<String> uploadVehiclePhoto({required XFile file}) async {
    final url = Uri.parse('TU_BASE_URL/upload-photo');

    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to upload image ${response.statusCode}: ${response.body}',
      );
    }

    final jsonResponse = json.decode(response.body);
    final photoUrl = jsonResponse['photo_url'];

    if (photoUrl is! String || photoUrl.isEmpty) {
      throw Exception(
        'Upload successful but photo_url is missing in response.',
      );
    }

    return photoUrl;
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
      'price_per_day': pricePerDay,
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

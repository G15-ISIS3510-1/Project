// lib/data/repositories/vehicle_repository.dart
import 'dart:convert';
import 'package:flutter_app/app/utils/pagination.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/data/models/vehicle_model.dart';
import 'package:flutter_app/data/sources/remote/vehicle_remote_source.dart';
import 'package:flutter/foundation.dart'; // (you already had this imported)
import 'package:flutter_app/app/utils/lru_cache.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> list();
  Future<Paginated<Vehicle>> listPaginated({int skip, int limit});
  Future<Vehicle> getById(String vehicleId);
  Future<String> uploadVehiclePhoto({required XFile file});
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
  });
}

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleService remote;

  // Page-cache (100-vehicle pages) keyed by "skip". Low impact but harmless.
  final LruCache<int, Paginated<Vehicle>> _pageCache =
      LruCache<int, Paginated<Vehicle>>(3);

  // NEW: hot-detail cache for specific vehicles by ID.
  // Capacity decision:
  //   - 20 means "remember the last ~20 detail screens the user opened".
  //   - If they open 21st unique vehicle, the least recently viewed is evicted.
  final LruCache<String, Vehicle> _vehicleDetailCache =
      LruCache<String, Vehicle>(20);

  VehicleRepositoryImpl({required this.remote});

  void clearCache() {
    _pageCache.clear();
    _vehicleDetailCache.clear();
  }

  @override
  Future<Paginated<Vehicle>> listPaginated({
    int skip = 0,
    int limit = 100,
  }) async {
    // Try LRU for this chunk first
    final cached = _pageCache.get(skip);
    if (cached != null && (cached.limit == 0 || cached.limit == limit)) {
      return cached;
    }

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
    return page.items;
  }

  @override
  Future<Vehicle> getById(String vehicleId) async {
    // 1. Try detail LRU first
    final cached = _vehicleDetailCache.get(vehicleId);
    if (cached != null) {
      debugPrint(
        '[VehicleRepository] getById("$vehicleId") -> LRU HIT '
        '(cache size=${_vehicleDetailCache.length})',
      );
      return cached;
    }

    // 2. Cache miss, go to network
    debugPrint(
      '[VehicleRepository] getById("$vehicleId") -> LRU MISS, fetching remote...',
    );

    final res = await remote.getById(vehicleId);

    if (res.statusCode != 200) {
      debugPrint(
        '[VehicleRepository] getById("$vehicleId") -> remote ERROR '
        '${res.statusCode}: ${res.body}',
      );
      throw Exception('Get vehicle ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);

    Vehicle v;
    if (decoded is List && decoded.isNotEmpty) {
      v = Vehicle.fromJson(decoded.first as Map<String, dynamic>);
    } else if (decoded is Map<String, dynamic>) {
      v = Vehicle.fromJson(decoded);
    } else {
      debugPrint(
        '[VehicleRepository] getById("$vehicleId") -> remote payload not understood',
      );
      throw Exception('Unexpected vehicle payload');
    }

    // 3. Store in LRU so next time we hit the fast path
    _vehicleDetailCache.put(vehicleId, v);
    debugPrint(
      '[VehicleRepository] getById("$vehicleId") -> stored in LRU '
      '(cache size=${_vehicleDetailCache.length})',
    );

    return v;
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

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      final id1 = decoded['vehicle_id'];
      if (id1 is String && id1.isNotEmpty) {
        // you may also put this new Vehicle in _vehicleDetailCache if you built it.
        return id1;
      }

      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final id2 = data['vehicle_id'];
        if (id2 is String && id2.isNotEmpty) {
          return id2;
        }
      }

      // Fallback: if backend actually returned a full vehicle
      try {
        final v = Vehicle.fromJson(decoded);
        if (v.vehicle_id.isNotEmpty) {
          _vehicleDetailCache.put(v.vehicle_id, v); // warm cache
          return v.vehicle_id;
        }
      } catch (_) {}
    }

    throw Exception(
      'Vehicle created but vehicle_id missing in response: ${res.body}',
    );
  }
}

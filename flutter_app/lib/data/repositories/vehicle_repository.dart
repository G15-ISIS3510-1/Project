// lib/data/repositories/vehicle_repository.dart
import 'dart:convert';
import 'package:flutter_app/app/utils/pagination.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/data/models/vehicle_model.dart';
import 'package:flutter_app/data/sources/remote/vehicle_remote_source.dart';
import 'package:flutter/foundation.dart'; // compute(), debugPrint
import 'package:flutter_app/app/utils/lru_cache.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> list();
  Future<Paginated<Vehicle>> listPaginated({int skip, int limit});
  Future<Vehicle> getById(String vehicleId);

  /// — Implemented with Future handlers (.then) —
  Future<String> uploadVehiclePhoto({required XFile file});

  /// — Implemented with Future handler + async/await inside the handler —
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

  // Page-cache (100-vehicle pages) keyed by "skip".
  final LruCache<int, Paginated<Vehicle>> _pageCache =
      LruCache<int, Paginated<Vehicle>>(3);

  // Hot-detail cache by vehicle ID.
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
    // Try LRU fast-path
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

    // --- NEW: Offload JSON decode to a background isolate with compute() ---
    // We pass the raw response body to a top-level function that returns
    // a simple Map (only sendable types cross isolate boundaries).
    final decodedMeta = await compute(_decodeVehiclePageOnIsolate, res.body);

    // Build typed models on the main isolate (cheap compared to decoding).
    final items = (decodedMeta['items'] as List)
        .cast<Map<String, dynamic>>()
        .map((m) => Vehicle.fromJson(m))
        .toList(growable: false);

    final page = Paginated<Vehicle>(
      items: items,
      total: decodedMeta['total'] as int? ?? items.length,
      hasMore: decodedMeta['hasMore'] as bool? ?? false,
      limit: decodedMeta['limit'] as int? ?? limit,
      skip: decodedMeta['skip'] as int? ?? skip,
    );

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
    // 1) LRU cache
    final cached = _vehicleDetailCache.get(vehicleId);
    if (cached != null) {
      debugPrint(
        '[VehicleRepository] getById("$vehicleId") -> LRU HIT (cache size=${_vehicleDetailCache.length})',
      );
      return cached;
    }

    // 2) Network
    debugPrint(
      '[VehicleRepository] getById("$vehicleId") -> LRU MISS, fetching remote...',
    );

    final res = await remote.getById(vehicleId);
    if (res.statusCode != 200) {
      debugPrint(
        '[VehicleRepository] getById("$vehicleId") -> remote ERROR ${res.statusCode}: ${res.body}',
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

    // 3) Warm LRU
    _vehicleDetailCache.put(vehicleId, v);
    debugPrint(
      '[VehicleRepository] getById("$vehicleId") -> stored in LRU (cache size=${_vehicleDetailCache.length})',
    );

    return v;
  }

  // ---------------------------------------------------------------------------
  // Future with handler (.then chain) — no async/await
  // ---------------------------------------------------------------------------
  @override
  Future<String> uploadVehiclePhoto({required XFile file}) {
    // NOTE: Replace with your real upload endpoint if different.
    final url = Uri.parse('TU_BASE_URL/upload-photo');

    // Chain the async steps instead of awaiting them.
    return http.MultipartFile.fromPath('file', file.path)
        .then((multipart) {
          final request = http.MultipartRequest('POST', url)..files.add(multipart);
          return request.send();
        })
        .then((streamedResponse) => http.Response.fromStream(streamedResponse))
        .then((response) {
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
        });
    // Any error will propagate through the chain as a failed Future.
  }

  // ---------------------------------------------------------------------------
  // Future handler + async/await inside the handler
  //   - We chain .then() on the network Future,
  //   - and mark the handler as async to use await for parsing/caching.
  // ---------------------------------------------------------------------------
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
  }) {
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

    // Handler returns Future<String>; inside we can use await if needed.
    return remote.createVehicle(body).then((res) async {
      if (res.statusCode != 201 && res.statusCode != 200) {
        throw Exception('Create vehicle ${res.statusCode}: ${res.body}');
      }

      final decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        final id1 = decoded['vehicle_id'];
        if (id1 is String && id1.isNotEmpty) {
          return id1;
        }

        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          final id2 = data['vehicle_id'];
          if (id2 is String && id2.isNotEmpty) {
            return id2;
          }
        }

        // Fallback: backend returned a full object
        try {
          final v = Vehicle.fromJson(decoded);
          if (v.vehicle_id.isNotEmpty) {
            _vehicleDetailCache.put(v.vehicle_id, v); // warm LRU
            return v.vehicle_id;
          }
        } catch (_) {/* ignore */}
      }

      throw Exception(
        'Vehicle created but vehicle_id missing in response: ${res.body}',
      );
    });
  }
}

/// ---------------------------------------------------------------------------
/// TOP-LEVEL isolate parser for vehicle pages
/// This function MUST be top-level (or static) to be used with compute().
/// It returns only sendable types (Map/List/num/bool/String) so it can cross
/// isolate boundaries. We keep it tolerant with different backend shapes:
///  - Top-level array
///  - {"items":[...], "total":..., "has_more"/"hasMore":..., "limit":..., "skip":...}
///  - {"data": {"items":[...], ...}}
/// ---------------------------------------------------------------------------
Map<String, dynamic> _decodeVehiclePageOnIsolate(String body) {
  final raw = jsonDecode(body);

  List<Map<String, dynamic>> items = const [];
  int? total;
  bool? hasMore;
  int? limit;
  int? skip;

  if (raw is List) {
    // Plain array payload
    items = raw.cast<Map>().map((e) => (e as Map).cast<String, dynamic>()).toList();
    total = items.length;
    hasMore = false;
    limit = 0;
    skip = 0;
  } else if (raw is Map<String, dynamic>) {
    Map<String, dynamic> source = raw;

    // Some backends nest under "data"
    if (source['data'] is Map<String, dynamic>) {
      source = source['data'] as Map<String, dynamic>;
    }

    final itemsAny = source['items'];
    if (itemsAny is List) {
      items = itemsAny
          .cast<Map>()
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();
    } else if (source['results'] is List) {
      // Alternate key name
      items = (source['results'] as List)
          .cast<Map>()
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();
    } else {
      // Unexpected shape: try to lift a single object to list
      if (source.isNotEmpty) {
        items = [source];
      } else {
        items = const [];
      }
    }

    total = (source['total'] is int)
        ? source['total'] as int
        : items.length;

    // Allow both snake_case and camelCase
    final hm = source['has_more'];
    final hM = source['hasMore'];
    hasMore = (hm is bool)
        ? hm
        : (hM is bool)
            ? hM
            : false;

    limit = (source['limit'] is int) ? source['limit'] as int : 0;
    skip = (source['skip'] is int) ? source['skip'] as int : 0;
  } else {
    // Fallback
    items = const [];
    total = 0;
    hasMore = false;
    limit = 0;
    skip = 0;
  }

  return <String, dynamic>{
    'items': items,
    'total': total,
    'hasMore': hasMore,
    'limit': limit,
    'skip': skip,
  };
}

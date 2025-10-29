// lib/data/repositories/availability_repository.dart
//
// This repo is responsible for fetching vehicle availability windows.
// We now add an LRU cache so we don't keep hammering the backend every time
// the user re-opens the same vehicle.
//

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_app/app/utils/pagination.dart';
import 'package:flutter_app/app/utils/result.dart';
import 'package:flutter_app/app/utils/lru_cache.dart';

import 'package:flutter_app/data/models/availability_model.dart';
import 'package:flutter_app/data/sources/remote/availability_remote_source.dart';

/// One page of availability data coming from backend pagination.
class AvailabilityPage {
  final List<AvailabilityWindow> items;
  final bool hasMore;
  AvailabilityPage({required this.items, required this.hasMore});
}

/// Public contract for availability fetching.
///
/// We now expose:
///  - listByVehiclePage(...) : fetch ONE page (skip/limit)
///  - getAllByVehicle(...)   : fetch + merge ALL pages for a vehicle,
///                             with LRU caching per vehicleId
abstract class AvailabilityRepository {
  /// Fetch a single page of raw availability for [vehicleId].
  /// This is basically the old listMyAvailability(), still useful internally.
  Future<Result<AvailabilityPage>> listByVehiclePage(
    String vehicleId, {
    int skip,
    int limit,
  });

  /// Fetch *all* availability windows for that vehicle, merging pages,
  /// and cache them in an LRU keyed by vehicleId.
  ///
  /// If [forceRefresh] is false (default), we'll return cached data if present.
  /// If [forceRefresh] is true, we ignore cache and hit the network again.
  Future<Result<List<AvailabilityWindow>>> getAllByVehicle(
    String vehicleId, {
    bool forceRefresh,
  });
}

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final AvailabilityService _remote;

  // LRU cache of recently-viewed vehicles' availability.
  // Key: vehicleId
  // Val: full merged list of AvailabilityWindow for that vehicle.
  //
  // Capacity decision:
  // - We don't expect the user to deep-inspect more than ~20 cars per session.
  // - Keeping ~20 * (a few dozen windows each) is cheap in RAM.
  final LruCache<String, List<AvailabilityWindow>> _availCache =
      LruCache<String, List<AvailabilityWindow>>(20);

  AvailabilityRepositoryImpl({required AvailabilityService remote})
    : _remote = remote;

  /// Low-level: fetch ONE page (skip/limit) for a vehicle.
  /// This is basically your old `listByVehicle`, refactored.
  @override
  Future<Result<AvailabilityPage>> listByVehiclePage(
    String vehicleId, {
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final res = await _remote.getByVehicle(
        vehicleId,
        skip: skip,
        limit: limit,
      );

      if (res.statusCode == 404) {
        // Vehicle has no availability
        return Result.ok(AvailabilityPage(items: const [], hasMore: false));
      }

      if (res.statusCode != 200) {
        return Result.err(
          'Error al cargar disponibilidad (${res.statusCode}): ${res.body}',
        );
      }

      // Parse in a background isolate to avoid blocking UI.
      final page = await compute(_parseAvailabilityPage, res.body);
      return Result.ok(page);
    } catch (e) {
      return Result.err('No se pudo cargar la disponibilidad: $e');
    }
  }

  /// High-level: get the *full* availability list for a vehicle.
  /// We will:
  ///   1. Check LRU cache
  ///   2. If miss, fetch all pages (100 at a time) until hasMore=false
  ///   3. Merge results and cache them under that vehicleId
  ///
  /// This is what CreateBookingScreen should now call.
  @override
  Future<Result<List<AvailabilityWindow>>> getAllByVehicle(
    String vehicleId, {
    bool forceRefresh = false,
  }) async {
    // 1. cache check
    if (!forceRefresh) {
      final cached = _availCache.get(vehicleId);
      if (cached != null) {
        assert(() {
          print(
            '[AvailabilityRepo] cache HIT for $vehicleId '
            '(windows=${cached.length})',
          );
          return true;
        }());
        return Result.ok(cached);
      }
    }

    assert(() {
      print(
        '[AvailabilityRepo] cache MISS for $vehicleId — fetching all pages',
      );
      return true;
    }());

    // 2. fetch all pages using listByVehiclePage in a loop
    const int pageSize = 100;
    int skip = 0;
    bool hasMore = true;
    final List<AvailabilityWindow> accumulator = [];

    while (hasMore) {
      final pageRes = await listByVehiclePage(
        vehicleId,
        skip: skip,
        limit: pageSize,
      );

      if (pageRes.isErr) {
        // If we have nothing so far, bubble the error.
        // If we already have partial data, treat it as "best effort".
        if (accumulator.isEmpty) {
          return Result.err(pageRes.errOrNull ?? 'Error desconocido');
        } else {
          break;
        }
      }

      final page = pageRes.okOrNull!;
      accumulator.addAll(page.items);
      hasMore = page.hasMore;

      if (hasMore) {
        skip += pageSize;
      }
    }

    // 3. Cache merged list in LRU (so reopening same car is instant)
    _availCache.put(vehicleId, accumulator);

    return Result.ok(accumulator);
  }

  // ---------- static parser used by compute() ----------

  /// This runs in a background isolate.
  /// It decodes backend JSON → Paginated<Map> → List<AvailabilityWindow>.
  static AvailabilityPage _parseAvailabilityPage(String body) {
    // We reuse the generic pagination util.
    final raw = parsePaginated<Map<String, dynamic>>(
      body,
      (m) => m, // keep raw maps first
    );

    final items = raw.items
        .map<AvailabilityWindow>(AvailabilityWindow.fromJson)
        .toList(growable: false);

    return AvailabilityPage(items: items, hasMore: raw.hasMore);
  }
}

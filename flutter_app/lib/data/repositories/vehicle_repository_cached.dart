import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/utils/pagination.dart';
import 'package:flutter_app/data/database/daos/vehicles_dao.dart';
import 'package:flutter_app/data/database/daos/infra_dao.dart';
import 'package:flutter_app/data/mappers/vehicle_db_mapper.dart';
import 'package:flutter_app/data/models/vehicle_model.dart';
import 'package:flutter_app/data/repositories/vehicle_repository.dart';
import 'package:image_picker/image_picker.dart';

/// Decorador que añade caché local (Drift) sin cambiar la interfaz pública.
class VehicleRepositoryCached implements VehicleRepository {
  final VehicleRepositoryImpl remoteRepo; // tu impl con LRU en memoria
  final VehiclesDao vehiclesDao; // Drift DAO (listAll, byId, upsertAll)
  final InfraDao infraDao; // estado (lastFetchAt, etag, pageCursor)

  VehicleRepositoryCached({
    required this.remoteRepo,
    required this.vehiclesDao,
    required this.infraDao,
  });

  /// Útil para logout: limpia LRU del remoto y resetea estado en infra.
  void clearCache() {
    try {
      remoteRepo.clearCache();
    } catch (_) {}
    infraDao
        .saveState(
          entity: 'vehicles',
          lastFetchAt: DateTime.fromMillisecondsSinceEpoch(0),
          etag: null,
          pageCursor: null,
        )
        .catchError((_) {});
  }

  // -------------------- LIST PAGINATED --------------------

  @override
  Future<Paginated<Vehicle>> listPaginated({
    int skip = 0,
    int limit = 100,
  }) async {
    // 1) DB-first: “paginado pobre” con slice en memoria.
    try {
      final rows = await vehiclesDao.listAll(); // isDeleted=false
      if (rows.isNotEmpty) {
        final models = rows.map((e) => e.toModel()).toList(growable: false);

        final start = (skip < 0)
            ? 0
            : (skip > models.length ? models.length : skip);
        final end = (start + limit > models.length)
            ? models.length
            : start + limit;
        final slice = models.sublist(start, end);

        // refresco silencioso de la primera página
        if (skip == 0) {
          _refreshFirstPageInBackground(limit: limit);
        }

        return Paginated<Vehicle>(
          items: slice,
          total: models.length,
          hasMore: end < models.length,
          limit: limit,
          skip: skip,
        );
      }
    } catch (_) {
      // Si DB falla, continuamos a red.
    }

    // 2) Red (aprovecha LRU del repo remoto) y persistimos en DB.
    try {
      final page = await remoteRepo.listPaginated(skip: skip, limit: limit);

      await vehiclesDao.upsertAll(
        page.items.map((v) => vehicleModelToDb(v)).toList(growable: false),
      );
      await infraDao.saveState(
        entity: 'vehicles',
        lastFetchAt: DateTime.now().toUtc(),
        pageCursor: page.hasMore ? '${skip + limit}' : null,
      );

      return page;
    } on SocketException catch (_) {
      // 3) Offline total → página vacía.
      return Paginated<Vehicle>(
        items: const [],
        total: 0,
        hasMore: false,
        limit: limit,
        skip: skip,
      );
    }
  }

  Future<void> _refreshFirstPageInBackground({required int limit}) async {
    try {
      final page = await remoteRepo.listPaginated(skip: 0, limit: limit);
      await vehiclesDao.upsertAll(
        page.items.map((v) => vehicleModelToDb(v)).toList(growable: false),
      );
      await infraDao.saveState(
        entity: 'vehicles',
        lastFetchAt: DateTime.now().toUtc(),
        pageCursor: page.hasMore ? '$limit' : null,
      );
    } catch (_) {
      /* noop */
    }
  }

  // -------------------- LIST (convenience) --------------------

  @override
  Future<List<Vehicle>> list() async {
    try {
      final rows = await vehiclesDao.listAll();
      if (rows.isNotEmpty) {
        _refreshFirstPageInBackground(limit: 100);
        return rows.map((e) => e.toModel()).toList(growable: false);
      }
    } catch (_) {}
    final first = await listPaginated(skip: 0, limit: 100);
    return first.items;
  }

  // -------------------- GET BY ID --------------------

  @override
  Future<Vehicle> getById(String vehicleId) async {
    // 1) DB-first
    try {
      final cached = await vehiclesDao.byId(vehicleId);
      if (cached != null) {
        _refreshOneInBackground(vehicleId); // refresh sin bloquear
        return cached.toModel();
      }
    } catch (_) {}

    // 2) Red + persistencia
    final v = await remoteRepo.getById(vehicleId);
    await vehiclesDao.upsertAll([vehicleModelToDb(v)]);
    return v;
  }

  Future<void> _refreshOneInBackground(String id) async {
    try {
      final v = await remoteRepo.getById(id);
      await vehiclesDao.upsertAll([vehicleModelToDb(v)]);
    } catch (_) {
      /* noop */
    }
  }

  // -------------------- UPLOAD PHOTO --------------------
  // Nuevo contrato: requiere vehicleId para POST /api/vehicles/{id}/upload-photo

  @override
  Future<String> uploadVehiclePhoto({
    required String vehicleId,
    required XFile file,
  }) async {
    final url = await remoteRepo.uploadVehiclePhoto(
      vehicleId: vehicleId,
      file: file,
    );
    // Refrescar el detalle en background para que la UI vea la nueva foto.
    _refreshOneInBackground(vehicleId);
    return url;
  }

  // -------------------- CREATE VEHICLE --------------------

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
    final id = await remoteRepo.createVehicle(
      title: title,
      make: make,
      model: model,
      year: year,
      transmission: transmission,
      pricePerDay: pricePerDay,
      plate: plate,
      seats: seats,
      fuelType: fuelType,
      mileage: mileage,
      status: status,
      lat: lat,
      lng: lng,
      imageUrl: imageUrl,
    );

    // Precalienta DB para que detalle esté disponible enseguida.
    _refreshOneInBackground(id);
    return id;
  }
}

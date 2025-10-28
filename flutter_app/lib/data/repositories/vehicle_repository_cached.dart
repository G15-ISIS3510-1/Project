import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/utils/net.dart';
import 'package:flutter_app/data/database/daos/vehicles_dao.dart';
import 'package:flutter_app/data/database/daos/infra_dao.dart';
import 'package:flutter_app/data/mappers/vehicle_db_mapper.dart';
import 'package:flutter_app/data/models/vehicle_model.dart';
import 'package:flutter_app/data/repositories/vehicle_repository.dart';
import 'package:flutter_app/data/sources/remote/vehicle_remote_source.dart';
import 'package:image_picker/image_picker.dart';

/// Decorador: mantiene la MISMA interfaz y delega en tu implementación actual,
/// agregando cache local (Drift) sin cambiar contratos.
class VehicleRepositoryCached implements VehicleRepository {
  final VehicleRepositoryImpl remoteRepo; // tu repo actual
  final VehiclesDao vehiclesDao; // DAO local
  final InfraDao infraDao; // SyncState / PendingOps (si lo usas)

  VehicleRepositoryCached({
    required this.remoteRepo,
    required this.vehiclesDao,
    required this.infraDao,
  });

  /// LIST: no cambiamos contrato (Future<List<Vehicle>>).
  /// - Paso 1: intentamos precargar desde DB (opcional: puedes ignorarlo si prefieres).
  /// - Paso 2 (siempre): llamamos a la red usando tu repo actual y ACTUALIZAMOS la DB.
  @override
  Future<List<Vehicle>> list() async {
    // 1) Sirve cache de una:
    final cachedRows = await vehiclesDao.listAll();
    if (cachedRows.isNotEmpty) {
      // dispara refresh en background si hay red
      // ignore: unawaited_futures
      _refreshAllInBackground();
      return cachedRows.map((r) => r.toModel()).toList();
    }

    // 2) Si no hay cache, intenta red (con manejo de offline)
    try {
      final items = await remoteRepo.list();
      await vehiclesDao.upsertAll(
        items.map((e) => vehicleModelToDb(e)).toList(),
      );
      await infraDao.saveState(
        entity: 'vehicles',
        lastFetchAt: DateTime.now().toUtc(),
      );
      return items;
    } on SocketException catch (_) {
      // Sin internet y sin cache -> lista vacía (o lanza)
      return const <Vehicle>[];
    }
  }

  Future<void> _refreshAllInBackground() async {
    if (!await Net.isOnline()) return;
    try {
      final items = await remoteRepo.list();
      await vehiclesDao.upsertAll(
        items.map((e) => vehicleModelToDb(e)).toList(),
      );
      await infraDao.saveState(
        entity: 'vehicles',
        lastFetchAt: DateTime.now().toUtc(),
      );
    } catch (_) {
      /* no rompas UI */
    }
  }

  /// GET BY ID:
  /// - Intento rápido: DB local (si existe) -> si necesitas puedes retornarlo
  ///   inmediatamente, pero para no cambiar semántica, devolvemos la versión de red.
  /// - Red: como siempre, y luego upsert a DB.
  @override
  Future<Vehicle> getById(String vehicleId) async {
    // 1) (opcional) precarga del cache a la VM si la usas
    // ignore: unawaited_futures
    _warmOneInBackground(vehicleId);

    // 2) red como siempre
    final v = await remoteRepo.getById(vehicleId);

    // 3) upsert a DB
    await vehiclesDao.upsertAll([vehicleModelToDb(v)]);
    return v;
  }

  /// Subida de foto: delega 1:1 (no cambiamos nada).
  @override
  Future<String> uploadVehiclePhoto({required XFile file}) {
    return remoteRepo.uploadVehiclePhoto(file: file);
  }

  /// Create vehicle:
  /// - Delegamos igual que antes para no cambiar contrato.
  /// - Si quieres modo offline/outbox, lo agregamos como método NUEVO aparte para no romper.
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

    // (Opcional) refresco/GET para asegurar cache
    // ignore: unawaited_futures
    _refreshOneAndCache(id);
    return id;
  }

  // -------- Helpers internos (no rompen contrato) --------

  Future<void> _warmCacheInBackground() async {
    try {
      // esto no afecta al retorno de list(), solo precalienta UI si la usas
      await vehiclesDao.listAll();
    } catch (_) {}
  }

  Future<void> _warmOneInBackground(String id) async {
    try {
      await vehiclesDao.byId(id);
    } catch (_) {}
  }

  Future<void> _refreshOneAndCache(String id) async {
    try {
      final v = await remoteRepo.getById(id);
      await vehiclesDao.upsertAll([vehicleModelToDb(v)]);
    } catch (_) {}
  }
}

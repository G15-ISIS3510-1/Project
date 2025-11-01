// lib/data/sources/local/vehicle_local_source.dart
import 'package:flutter_app/data/database/app_database.dart';

import '../../database/daos/vehicles_dao.dart';
import '../../database/daos/infra_dao.dart';
import '../../mappers/vehicle_db_mapper.dart';
import '../../models/vehicle_model.dart' as vm; // ← importa tu modelo real

class VehicleLocalSource {
  final VehiclesDao vehiclesDao;
  final InfraDao infraDao;
  VehicleLocalSource(this.vehiclesDao, this.infraDao);

  // Lee del cache (DB) y retorna tu modelo de frontend
  Future<List<vm.Vehicle>> getCachedList() async {
    final rows = await vehiclesDao.listAll();
    return rows.map((e) => e.toModel()).toList(); // extension en el mapper
  }

  // Guarda en cache una lista de modelos (usa el helper del mapper)
  Future<void> cacheList(List<vm.Vehicle> items) async {
    await vehiclesDao.upsertAll(items.map((e) => vehicleModelToDb(e)).toList());
  }

  // También puedes cachear companions directamente si ya los tienes
  Future<void> cacheCompanions(List<VehiclesCompanion> companions) async {
    await vehiclesDao.upsertAll(companions);
  }

  Future<void> saveListCheckpoint({
    DateTime? lastFetchAt,
    String? etag,
    String? cursor,
  }) {
    return infraDao.saveState(
      entity: 'vehicles',
      lastFetchAt: lastFetchAt,
      etag: etag,
      pageCursor: cursor,
    );
  }
}

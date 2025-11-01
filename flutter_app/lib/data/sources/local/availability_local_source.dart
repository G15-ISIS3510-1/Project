import '../../database/daos/vehicle_availability_dao.dart';
import '../../database/daos/infra_dao.dart';
import '../../mappers/availability_db_mapper.dart';
import '../../models/availability_model.dart';

class AvailabilityLocalSource {
  final VehicleAvailabilityDao dao;
  final InfraDao infra;
  AvailabilityLocalSource(this.dao, this.infra);

  Future<List<AvailabilityWindow>> getPage({
    required String vehicleId,
    required int skip,
    required int limit,
  }) async {
    final rows = await dao.byVehiclePaged(
      vehicleId: vehicleId,
      limit: limit,
      offset: skip,
    );
    return rows.map((r) => r.toModel()).toList(growable: false);
  }

  Future<List<AvailabilityWindow>> getByVehicleInRange(
    String vehicleId,
    DateTime from,
    DateTime to,
  ) async {
    final rows = await dao.byVehicleAndRange(vehicleId, from, to);
    return rows.map((r) => r.toModel()).toList();
  }

  Future<void> cacheJsonList(List<Map<String, dynamic>> items) async {
    await dao.upsertAll(items.map(availabilityJsonToDb).toList());
  }

  Future<void> cacheModels(List<AvailabilityWindow> items) async {
    await dao.upsertAll(items.map(availabilityModelToDb).toList());
  }

  Future<void> setCheckpoint({
    String entity = 'availability',
    DateTime? lastFetchAt,
    String? cursor,
  }) {
    return infra.saveState(
      entity: entity,
      lastFetchAt: lastFetchAt,
      pageCursor: cursor,
    );
  }
}

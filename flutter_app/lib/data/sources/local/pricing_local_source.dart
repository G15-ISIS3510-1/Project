import '../../database/daos/pricing_dao.dart';
import '../../database/daos/infra_dao.dart';
import '../../mappers/pricing_db_mapper.dart';
import '../../models/pricing_model.dart' as vm;

class PricingLocalSource {
  final PricingDao dao;
  final InfraDao infra;

  PricingLocalSource(this.dao, this.infra);

  Future<List<vm.Pricing>> getByVehicle({
    required String vehicleId,
    int skip = 0,
    int limit = 50,
  }) async {
    final rows = await dao.listByVehicle(
      vehicleId: vehicleId,
      limit: limit,
      offset: skip,
    );
    return rows.map((e) => e.toModel()).toList(growable: false);
  }

  Future<void> cacheModels(List<vm.Pricing> items) async {
    await dao.upsertAll(items.map(pricingModelToDb).toList());
  }

  Future<void> checkpoint({
    required String vehicleId,
    DateTime? lastFetchAt,
    String? cursor,
  }) {
    return infra.saveState(
      entity: 'pricing:$vehicleId',
      lastFetchAt: lastFetchAt,
      pageCursor: cursor,
    );
  }
}

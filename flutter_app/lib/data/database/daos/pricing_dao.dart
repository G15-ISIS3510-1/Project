import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/pricing_table.dart';

part 'pricing_dao.g.dart';

@DriftAccessor(tables: [Pricings])
class PricingDao extends DatabaseAccessor<AppDatabase> with _$PricingDaoMixin {
  PricingDao(AppDatabase db) : super(db);

  Future<void> upsertAll(List<PricingsCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(pricings, rows));
  }

  Future<int> clearAll() => delete(pricings).go();

  Future<List<PricingData>> listByVehicle({
    required String vehicleId,
    int limit = 50,
    int offset = 0,
  }) {
    final q =
        (select(pricings)..where(
            (t) => t.vehicleId.equals(vehicleId) & t.isDeleted.equals(false),
          ))
          ..limit(limit, offset: offset);
    return q.get();
  }

  Future<PricingData?> byId(String pricingId) {
    return (select(
      pricings,
    )..where((t) => t.pricingId.equals(pricingId))).getSingleOrNull();
  }

  Future<void> softDelete(String pricingId) async {
    await (update(pricings)..where((t) => t.pricingId.equals(pricingId))).write(
      const PricingsCompanion(isDeleted: Value(true)),
    );
  }
}

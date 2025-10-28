import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/vehicles_table.dart';
part 'vehicles_dao.g.dart';

@DriftAccessor(tables: [Vehicles])
class VehiclesDao extends DatabaseAccessor<AppDatabase>
    with _$VehiclesDaoMixin {
  VehiclesDao(AppDatabase db) : super(db);

  Future<void> upsertAll(List<VehiclesCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(vehicles, rows));
  }

  Future<List<VehiclesData>> listAll() =>
      (select(vehicles)..where((t) => t.isDeleted.equals(false))).get();

  Future<VehiclesData?> byId(String id) => (select(
    vehicles,
  )..where((t) => t.vehicleId.equals(id))).getSingleOrNull();
}

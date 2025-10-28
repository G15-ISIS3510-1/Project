import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/vehicle_availability_table.dart';

part 'vehicle_availability_dao.g.dart';

@DriftAccessor(tables: [VehicleAvailability])
class VehicleAvailabilityDao extends DatabaseAccessor<AppDatabase>
    with _$VehicleAvailabilityDaoMixin {
  VehicleAvailabilityDao(AppDatabase db) : super(db);

  Future<void> upsertAll(List<VehicleAvailabilityCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(vehicleAvailability, rows));
  }

  Future<List<VehicleAvailabilityData>> byVehicleAndRange(
    String vehicleId,
    DateTime from,
    DateTime to,
  ) {
    return (select(vehicleAvailability)
          ..where(
            (t) =>
                t.vehicleId.equals(vehicleId) &
                t.isDeleted.equals(false) &
                t.startTs.isSmallerOrEqualValue(to.toUtc()) &
                t.endTs.isBiggerOrEqualValue(from.toUtc()),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.startTs)]))
        .get();
  }

  Future<void> softDelete(String availabilityId) async {
    await (update(vehicleAvailability)
          ..where((t) => t.availabilityId.equals(availabilityId)))
        .write(const VehicleAvailabilityCompanion(isDeleted: Value(true)));
  }

  Future<List<VehicleAvailabilityData>> byVehiclePaged({
    required String vehicleId,
    required int limit,
    required int offset,
  }) {
    final q =
        (select(vehicleAvailability)
            ..where(
              (t) => t.vehicleId.equals(vehicleId) & t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.startTs)]))
          ..limit(limit, offset: offset);
    return q.get();
  }
}

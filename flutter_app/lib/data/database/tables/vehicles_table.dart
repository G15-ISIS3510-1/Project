import 'package:drift/drift.dart';

@DataClassName('VehiclesData')
class Vehicles extends Table {
  TextColumn get vehicleId => text()();
  TextColumn get ownerId => text()();
  TextColumn get make => text()();
  TextColumn get model => text()();
  IntColumn get year => integer()();
  TextColumn get plate => text()();
  IntColumn get seats => integer()();
  TextColumn get transmission => text()();
  TextColumn get fuelType => text()();
  IntColumn get mileage => integer()();
  TextColumn get status => text()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {vehicleId};
}

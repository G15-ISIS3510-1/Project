import 'package:drift/drift.dart';

@DataClassName('VehicleAvailabilityData') // fuerza el nombre del row
class VehicleAvailability extends Table {
  TextColumn get availabilityId => text()(); // UUID
  TextColumn get vehicleId => text()(); // FK lógico
  DateTimeColumn get startTs => dateTime()(); // UTC
  DateTimeColumn get endTs => dateTime()(); // UTC
  TextColumn get type => text()(); // 'available'|'blocked'|'maintenance'
  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {availabilityId};
}

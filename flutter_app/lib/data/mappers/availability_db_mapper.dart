import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/vehicle_availability_table.dart';

// 👇 IMPORTA EL MODELO (no la tabla)
import '../models/availability_model.dart';

/// DB row -> Modelo (sin fromJson)
extension AvailabilityRowToModel on VehicleAvailabilityData {
  AvailabilityWindow toModel() => AvailabilityWindow(
    availability_id: availabilityId,
    vehicle_id: vehicleId,
    start: startTs, // ya es DateTime
    end: endTs, // ya es DateTime
    type: type,
    notes: notes,
  );
}

/// Modelo -> DB (sin toJson)
VehicleAvailabilityCompanion availabilityModelToDb(AvailabilityWindow v) {
  // start_ts / end_ts pueden venir como DateTime o String ISO
  DateTime _asDateTime(Object? x) {
    if (x == null) return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    if (x is DateTime) return x.toUtc();
    return DateTime.parse(x as String).toUtc();
  }

  return VehicleAvailabilityCompanion(
    availabilityId: Value(v.availability_id),
    vehicleId: Value(v.vehicle_id),
    startTs: Value(_asDateTime(v.start)),
    endTs: Value(_asDateTime(v.end)),
    type: Value(v.type),
    notes: Value(v.notes),
    isDeleted: const Value(false),
  );
}

/// JSON del backend -> DB (por si cacheas directamente la respuesta HTTP)
VehicleAvailabilityCompanion availabilityJsonToDb(Map<String, dynamic> j) {
  DateTime _p(Object? v) =>
      v is DateTime ? v.toUtc() : DateTime.parse(v as String).toUtc();

  return VehicleAvailabilityCompanion(
    availabilityId: Value(j['availability_id'] as String),
    vehicleId: Value(j['vehicle_id'] as String),
    startTs: Value(_p(j['start_ts'])),
    endTs: Value(_p(j['end_ts'])),
    type: Value(j['type'] as String),
    notes: Value(j['notes'] as String?),
    isDeleted: const Value(false),
  );
}

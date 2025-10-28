import 'package:drift/drift.dart';
import '../database/app_database.dart';

// 👇 Ajusta el import si tu ruta difiere
import '../models/vehicle_model.dart' as vm;

/// DB row -> tu modelo (usando fromJson para no depender de constructores/campos)
extension VehicleRowToModel on VehiclesData {
  vm.Vehicle toModel() => vm.Vehicle.fromJson({
    'vehicle_id': vehicleId,
    'owner_id': ownerId,
    'make': make,
    'model': model,
    'year': year,
    'plate': plate,
    'seats': seats,
    'transmission': transmission,
    'fuel_type': fuelType,
    'mileage': mileage,
    'status': status,
    'lat': lat,
    'lng': lng,
    'photo_url': photoUrl,
    'created_at': createdAt.toIso8601String(),
  });
}

/// JSON (del backend) -> DB (cache sin instanciar el modelo)
VehiclesCompanion vehicleJsonToDb(Map<String, dynamic> j) {
  final created = j['created_at'] is String
      ? DateTime.parse(j['created_at'] as String)
      : (j['created_at'] as DateTime);

  return VehiclesCompanion(
    vehicleId: Value(j['vehicle_id'] as String),
    ownerId: Value(j['owner_id'] as String),
    make: Value(j['make'] as String),
    model: Value(j['model'] as String),
    year: Value(j['year'] as int),
    plate: Value(j['plate'] as String),
    seats: Value(j['seats'] as int),
    transmission: Value(j['transmission'] as String),
    fuelType: Value(j['fuel_type'] as String),
    mileage: Value(j['mileage'] as int),
    status: Value(j['status'] as String),
    lat: Value((j['lat'] as num).toDouble()),
    lng: Value((j['lng'] as num).toDouble()),
    photoUrl: Value(j['photo_url'] as String?),
    createdAt: Value(created),
    isDeleted: const Value(false),
  );
}

/// (Opcional) Modelo -> DB si tu `Vehicle` tiene `toJson()`.
/// Si no tiene `toJson()`, usa `vehicleJsonToDb(...)` directamente donde tengas el Map.
VehiclesCompanion vehicleModelToDb(vm.Vehicle v) {
  final j = v
      .toJson(); // <-- si no existe, cambia a tu método equivalente o elimina esta función
  return vehicleJsonToDb(j);
}

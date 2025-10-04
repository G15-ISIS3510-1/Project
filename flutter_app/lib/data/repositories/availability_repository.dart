import 'dart:convert';

import 'package:flutter_app/data/models/availability_model.dart';
import 'package:flutter_app/data/sources/remote/availability_remote_source.dart';

abstract class AvailabilityRepository {
  /// Devuelve las ventanas de disponibilidad para un vehículo.
  /// Si en el futuro agregas caché local, usa [forceRefresh] para saltarla.
  Future<List<AvailabilityWindow>> listByVehicle(
    String vehicleId, {
    bool forceRefresh = false,
  });

  // Si luego agregas endpoints en tu backend:
  // Future<AvailabilityWindow> create(AvailabilityWindow input);
  // Future<void> delete(String availabilityId);
  // Future<AvailabilityWindow> update(AvailabilityWindow input);
}

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final AvailabilityService _remote;
  // final AvailabilityLocalSource? _local; // <-- por si luego agregas cache

  AvailabilityRepositoryImpl({
    required AvailabilityService remote,
    // AvailabilityLocalSource? local,
  }) : _remote = remote;

  @override
  Future<List<AvailabilityWindow>> listByVehicle(
    String vehicleId, {
    bool forceRefresh = false,
  }) async {
    // Red (remote)
    final res = await _remote.getByVehicle(vehicleId);

    if (res.statusCode == 404) {
      // No hay disponibilidad para ese vehículo → lista vacía
      return <AvailabilityWindow>[];
    }
    if (res.statusCode != 200) {
      // Normaliza el error a una excepción de dominio si quieres
      // (aquí usamos Exception simple para mantenerlo minimal)
      throw Exception(
        'Error al cargar disponibilidad (${res.statusCode}): ${res.body}',
      );
    }

    // Parseo a dominio
    final data = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    final windows = data.map(AvailabilityWindow.fromJson).toList();

    return windows;
  }

  // Ejemplos para cuando tengas endpoints en backend:
  // @override
  // Future<AvailabilityWindow> create(AvailabilityWindow input) async {
  //   final res = await _remote.createRaw({
  //     'vehicle_id': input.vehicle_id,
  //     'start_ts': input.start.toUtc().toIso8601String(),
  //     'end_ts': input.end.toUtc().toIso8601String(),
  //     'type': input.type,            // "available" | "blocked"
  //     'notes': input.notes,
  //   });
  //   if (res.statusCode != 201 && res.statusCode != 200) {
  //     throw Exception('No se pudo crear availability (${res.statusCode})');
  //   }
  //   final j = jsonDecode(res.body) as Map<String, dynamic>;
  //   return AvailabilityWindow.fromJson(j);
  // }
}

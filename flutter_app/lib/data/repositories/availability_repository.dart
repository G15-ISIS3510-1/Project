import 'dart:convert';
import 'package:flutter/foundation.dart'; // Added for compute()

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

    // Offload parsing to a background isolate
    return await compute(_parseAvailability, res.body);
  }

  // Top-level parser for availability list
  static List<AvailabilityWindow> _parseAvailability(String body) {
    final data = (jsonDecode(body) as List).cast<Map<String, dynamic>>();
    return data.map(AvailabilityWindow.fromJson).toList();
  }

  // Ejemplos para cuando tengas endpoints en backend:
  // @override
  // Future<AvailabilityWindow> create(AvailabilityWindow input) async {
  //   final res = await _remote.createRaw({...});
  //   ...
  // }
}

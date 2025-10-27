// lib/domain/availability/availability_repository.dart

import 'dart:convert';
import 'package:flutter/foundation.dart'; // compute()
import 'package:flutter_app/app/utils/pagination.dart';
import 'package:flutter_app/app/utils/result.dart';

import 'package:flutter_app/data/models/availability_model.dart';
import 'package:flutter_app/data/sources/remote/availability_remote_source.dart';

class AvailabilityPage {
  final List<AvailabilityWindow> items;
  final bool hasMore;
  AvailabilityPage({required this.items, required this.hasMore});
}

abstract class AvailabilityRepository {
  /// Devuelve una página de ventanas de disponibilidad para un vehículo.
  Future<Result<AvailabilityPage>> listByVehicle(
    String vehicleId, {
    int skip,
    int limit,
    bool forceRefresh,
  });

  // Si luego agregas endpoints en tu backend:
  // Future<AvailabilityWindow> create(AvailabilityWindow input);
  // Future<void> delete(String availabilityId);
  // Future<AvailabilityWindow> update(AvailabilityWindow input);
}

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final AvailabilityService _remote;
  // final AvailabilityLocalSource? _local;

  AvailabilityRepositoryImpl({
    required AvailabilityService remote,
    // AvailabilityLocalSource? local,
  }) : _remote = remote;

  @override
  Future<Result<AvailabilityPage>> listByVehicle(
    String vehicleId, {
    int skip = 0,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      // Red (remote) — se asume soporte de skip/limit en el service
      final res = await _remote.getByVehicle(
        vehicleId,
        skip: skip,
        limit: limit,
      );

      if (res.statusCode == 404) {
        // Sin disponibilidad -> página vacía
        return Result.ok(AvailabilityPage(items: const [], hasMore: false));
      }

      if (res.statusCode != 200) {
        return Result.err(
          'Error al cargar disponibilidad (${res.statusCode}): ${res.body}',
        );
      }

      // Offload del parseo y mapeo en isolate
      final page = await compute(_parseAvailabilityPage, res.body);
      return Result.ok(page);
    } catch (e) {
      return Result.err('No se pudo cargar la disponibilidad: $e');
    }
  }

  // ---------- parser top-level/static para compute ----------

  /// Parsea un body paginado y devuelve AvailabilityPage.
  static AvailabilityPage _parseAvailabilityPage(String body) {
    // 1) Parse genérico con util de paginación
    final raw = parsePaginated<Map<String, dynamic>>(
      body,
      (m) => m, // primero en bruto
    );

    // 2) Mapear a modelo de dominio
    final items = raw.items
        .map<AvailabilityWindow>(AvailabilityWindow.fromJson)
        .toList(growable: false);

    return AvailabilityPage(items: items, hasMore: raw.hasMore);
  }
}

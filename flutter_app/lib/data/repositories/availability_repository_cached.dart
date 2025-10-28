// lib/data/repositories/availability_repository_cached.dart

import 'package:flutter_app/app/utils/result.dart';
import 'package:flutter_app/data/models/availability_model.dart';
import 'package:flutter_app/data/repositories/availability_repository.dart';
import 'package:flutter_app/data/sources/local/availability_local_source.dart';

/// Decorator que añade caché local por página y “warm-up” de caché
/// al pedir todo el inventario de disponibilidad.
class AvailabilityRepositoryCached implements AvailabilityRepository {
  /// Usa la interfaz para poder envolver cualquier impl (incluida la tuya con LRU).
  final AvailabilityRepository remote;
  final AvailabilityLocalSource local;

  AvailabilityRepositoryCached({required this.remote, required this.local});

  /// Lee una página desde caché si aplica; si falla o hay forceRefresh, va a red.
  @override
  Future<Result<AvailabilityPage>> listByVehiclePage(
    String vehicleId, {
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      // 1) Intento de caché SOLO si es la primera página (convención típica).
      // Si quieres cache por cualquier página, elimina el skip==0.
      final cached = await local.getPage(
        vehicleId: vehicleId,
        skip: skip,
        limit: limit,
      );
      if (cached.isNotEmpty) {
        final hasMore = cached.length == limit;
        return Result.ok(AvailabilityPage(items: cached, hasMore: hasMore));
      }

      // 2) Red
      final res = await remote.listByVehiclePage(
        vehicleId,
        skip: skip,
        limit: limit,
      );

      // 3) Si fue OK, persiste y retorna
      final page = res.okOrNull;
      if (page != null) {
        // Persisto modelos “tal cual”
        await local.cacheModels(page.items);

        // Cursor simple: siguiente “skip” si hay más
        await local.setCheckpoint(
          entity: vehicleId,
          lastFetchAt: DateTime.now().toUtc(),
          cursor: page.hasMore ? '${skip + limit}' : null,
        );

        return res;
      }

      // 4) Si la red falló, intento caché (best-effort)
      final fallback = await local.getPage(
        vehicleId: vehicleId,
        skip: skip,
        limit: limit,
      );
      if (fallback.isNotEmpty) {
        final hasMore = fallback.length == limit;
        return Result.ok(AvailabilityPage(items: fallback, hasMore: hasMore));
      }

      return res; // Propago el error original
    } catch (e) {
      // 5) Excepción: intento caché como último recurso
      final fallback = await local.getPage(
        vehicleId: vehicleId,
        skip: skip,
        limit: limit,
      );
      if (fallback.isNotEmpty) {
        final hasMore = fallback.length == limit;
        return Result.ok(AvailabilityPage(items: fallback, hasMore: hasMore));
      }
      return Result.err('No se pudo cargar disponibilidad: $e');
    }
  }

  /// Devuelve TODO el arreglo de ventanas.
  /// Estrategia:
  ///  - Si existe materializable desde caché por páginas (0..n) -> úsalo.
  ///  - Si no hay caché suficiente o se pide forceRefresh -> voy a red,
  ///    guardo todo localmente y retorno.
  @override
  Future<Result<List<AvailabilityWindow>>> getAllByVehicle(
    String vehicleId, {
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        // Intento reconstruir TODO desde caché paginando hasta que una página < limit
        const int limit = 100;
        int skip = 0;
        final List<AvailabilityWindow> acc = [];

        while (true) {
          final page = await local.getPage(
            vehicleId: vehicleId,
            skip: skip,
            limit: limit,
          );

          if (page.isEmpty) break;

          acc.addAll(page);

          if (page.length < limit) {
            // Esta fue la última página almacenada
            return Result.ok(acc);
          }
          skip += limit;
        }
        // Si llegaste acá, no había caché suficiente -> sigue a red
      }

      // Red (usa la impl remota que ya hace loop + LRU en memoria)
      final res = await remote.getAllByVehicle(
        vehicleId,
        forceRefresh: forceRefresh,
      );

      final list = res.okOrNull;
      if (list != null) {
        // Warm-up de caché local: persisto todo y un checkpoint sin cursor
        await local.cacheModels(list);
        await local.setCheckpoint(
          entity: vehicleId,
          lastFetchAt: DateTime.now().toUtc(),
          cursor: null,
        );
        return Result.ok(list);
      }

      // Si la red falló, intento al menos reconstruir caché como arriba
      const int limit = 100;
      int skip = 0;
      final List<AvailabilityWindow> acc = [];

      while (true) {
        final page = await local.getPage(
          vehicleId: vehicleId,
          skip: skip,
          limit: limit,
        );
        if (page.isEmpty) break;
        acc.addAll(page);
        if (page.length < limit) break;
        skip += limit;
      }

      if (acc.isNotEmpty) return Result.ok(acc);

      return res; // sin caché disponible, devuelvo el error original
    } catch (e) {
      // Último intento de best-effort desde caché
      const int limit = 100;
      int skip = 0;
      final List<AvailabilityWindow> acc = [];
      while (true) {
        final page = await local.getPage(
          vehicleId: vehicleId,
          skip: skip,
          limit: limit,
        );
        if (page.isEmpty) break;
        acc.addAll(page);
        if (page.length < limit) break;
        skip += limit;
      }
      if (acc.isNotEmpty) return Result.ok(acc);
      return Result.err('No se pudo cargar disponibilidad: $e');
    }
  }
}

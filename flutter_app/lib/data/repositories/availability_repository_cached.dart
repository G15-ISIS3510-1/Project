import 'package:flutter_app/app/utils/result.dart';
import 'package:flutter_app/data/models/availability_model.dart' as vm;
import 'package:flutter_app/data/repositories/availability_repository.dart';
import 'package:flutter_app/data/sources/local/availability_local_source.dart';

class AvailabilityRepositoryCached implements AvailabilityRepository {
  final AvailabilityRepositoryImpl remoteRepo; // tu impl actual
  final AvailabilityLocalSource local;

  AvailabilityRepositoryCached({required this.remoteRepo, required this.local});

  @override
  Future<Result<AvailabilityPage>> listByVehicle(
    String vehicleId, {
    int skip = 0,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      // 1) (opcional) cache para primera página si no es forceRefresh
      if (!forceRefresh && skip == 0) {
        final cached = await local.getPage(
          vehicleId: vehicleId,
          skip: skip,
          limit: limit,
        );
        if (cached.isNotEmpty) {
          final hasMore = cached.length == limit;
          return Result.ok(AvailabilityPage(items: cached, hasMore: hasMore));
        }
      }

      // 2) Red
      final res = await remoteRepo.listByVehicle(
        vehicleId,
        skip: skip,
        limit: limit,
        forceRefresh: forceRefresh,
      );

      // 3) Si fue OK, cachea y retorna tal cual
      final page = res.okOrNull; // <<<<<<<<<<<<<< clave con tu Result<T>
      if (page != null) {
        await local.cacheModels(page.items);
        await local.setCheckpoint(
          entity: vehicleId,
          lastFetchAt: DateTime.now().toUtc(),
          cursor: page.hasMore ? '${skip + limit}' : null,
        );
        return res; // deja pasar el OK original
      }

      // 4) Fallback al cache si hubo error
      final cached = await local.getPage(
        vehicleId: vehicleId,
        skip: skip,
        limit: limit,
      );
      if (cached.isNotEmpty) {
        final hasMore = cached.length == limit;
        return Result.ok(AvailabilityPage(items: cached, hasMore: hasMore));
      }

      return res; // deja pasar el Err original si no hubo cache
    } catch (e) {
      // 5) Excepción dura -> intenta cache
      final cached = await local.getPage(
        vehicleId: vehicleId,
        skip: skip,
        limit: limit,
      );
      if (cached.isNotEmpty) {
        final hasMore = cached.length == limit;
        return Result.ok(AvailabilityPage(items: cached, hasMore: hasMore));
      }
      return Result.err('No se pudo cargar disponibilidad: $e');
    }
  }
}

import 'package:flutter_app/data/models/pricing_model.dart' as vm;
import 'package:flutter_app/data/models/suggested_price.dart' as vmsp;

import 'package:flutter_app/data/repositories/pricing_repository.dart'; // tu original
import 'package:flutter_app/data/sources/local/pricing_local_source.dart';
import 'package:flutter_app/data/stores/suggested_price_store.dart';

/// Decorador de cache para PricingRepository.
/// - No rompe firmas.
/// - Cache relacional (Drift) para getByVehicle.
/// - KV con TTL para suggestPrice.
///
/// Nota: Para guardar en KV tras el remoto en suggestPrice, necesitamos leer el
/// valor numérico del SuggestedPrice. Como la clase es tuya y no sabemos el nombre
/// del campo, recibe un extractor `priceGetter` al construir (ej: (sp) => sp.value).
class PricingRepositoryCached implements PricingRepository {
  final PricingRepositoryImpl remote; // tu impl actual
  final PricingLocalSource local; // cache relacional
  final SuggestedPriceStore suggestStore; // KV cache con TTL
  final double Function(vmsp.SuggestedPrice)
  priceGetter; // extractor del precio

  PricingRepositoryCached({
    required this.remote,
    required this.local,
    required this.suggestStore,
    required this.priceGetter,
  });

  /// 1) Lee cache rápido (si existe) y de todos modos va a red para mantener
  /// la UI fresca. Devuelve el remoto si llega; si el remoto es null, retorna cache.
  @override
  Future<vm.Pricing?> getByVehicle(String vehicleId) async {
    // fast-path opcional desde cache
    final cached = await local.getByVehicle(
      vehicleId: vehicleId,
      skip: 0,
      limit: 1,
    );
    final cachedOne = cached.isNotEmpty ? cached.first : null;

    // red
    final remoteOne = await remote.getByVehicle(vehicleId);

    if (remoteOne != null) {
      // actualiza cache
      await local.cacheModels([remoteOne]);
      await local.checkpoint(
        vehicleId: vehicleId,
        lastFetchAt: DateTime.now().toUtc(),
        cursor: null,
      );
      return remoteOne;
    }

    // si el server no tiene pricing, usa cache si había algo
    return cachedOne;
  }

  /// 2) Upsert delega al server y refresca el cache (GET).
  @override
  Future<void> upsertForVehicle({
    required String vehicleId,
    required double dailyPrice,
    String currency = 'USD',
    int minDays = 1,
    int maxDays = 30,
  }) async {
    await remote.upsertForVehicle(
      vehicleId: vehicleId,
      dailyPrice: dailyPrice,
      currency: currency,
      minDays: minDays,
      maxDays: maxDays,
    );

    // refresco de cache: volvemos a pedir al server y guardamos
    final after = await remote.getByVehicle(vehicleId);
    if (after != null) {
      await local.cacheModels([after]);
      await local.checkpoint(
        vehicleId: vehicleId,
        lastFetchAt: DateTime.now().toUtc(),
        cursor: null,
      );
    }
  }

  /// 3) SuggestPrice con KV cache (TTL por defecto en el store).
  /// - Si hay cache KV -> devuelve SuggestedPrice(cached, 'cached').
  /// - Si no hay cache -> pide a red, guarda en KV (usando priceGetter) y devuelve.
  @override
  Future<vmsp.SuggestedPrice?> suggestPrice({
    required Map<String, dynamic> form,
  }) async {
    // hit KV
    final cached = await suggestStore.load(request: form);
    if (cached != null) {
      return vmsp.SuggestedPrice(cached, 'cached');
    }

    // red
    final rsp = await remote.suggestPrice(form: form);
    if (rsp == null) return null;

    // guarda en KV usando el extractor proporcionado
    try {
      final price = priceGetter(rsp);
      await suggestStore.save(request: form, price: price);
    } catch (_) {
      // si no se pudo extraer el precio, igual devolvemos rsp sin cachearlo
    }

    return rsp;
  }
}

// import '../sources/remote/pricing_remote_source.dart';

// abstract class PricingRepository {
//   // TODO: define repository interface methods
// }

// class PricingRepositoryImpl implements PricingRepository {
//   final PricingRemoteSource remote;
//   PricingRepositoryImpl({required this.remote});
//   // TODO: implement methods using remote
// }

import 'dart:convert';

import 'package:flutter_app/data/models/pricing_model.dart';
import 'package:flutter_app/data/models/suggested_price.dart';
import 'package:flutter_app/data/sources/remote/pricing_remote_source.dart';

abstract class PricingRepository {
  Future<Pricing?> getByVehicle(String vehicleId);

  Future<void> upsertForVehicle({
    required String vehicleId,
    required double dailyPrice,
    String currency,
    int minDays,
    int maxDays,
  });

  Future<SuggestedPrice?> suggestPrice({required Map<String, dynamic> form});
}

class PricingRepositoryImpl implements PricingRepository {
  final PricingService remote;
  // final PricingLocalSource? local; // si luego agregas cache

  PricingRepositoryImpl({required this.remote});

  @override
  Future<Pricing?> getByVehicle(String vehicleId) async {
    final res = await remote.getByVehicle(vehicleId);

    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw Exception('Pricing getByVehicle ${res.statusCode}: ${res.body}');
    }

    final j = jsonDecode(res.body) as Map<String, dynamic>;
    return Pricing.fromJson(j);
  }

  @override
  Future<void> upsertForVehicle({
    required String vehicleId,
    required double dailyPrice,
    String currency = 'USD',
    int minDays = 1,
    int maxDays = 30,
  }) async {
    final res = await remote.upsertForVehicle(
      vehicleId: vehicleId,
      dailyPrice: dailyPrice,
      currency: currency,
      min_days: minDays,
      max_days: maxDays,
    );

    // Acepta 200/201; algunos backends también devuelven 204 (sin body).
    if (res.statusCode != 200 &&
        res.statusCode != 201 &&
        res.statusCode != 204) {
      throw Exception('Pricing upsert ${res.statusCode}: ${res.body}');
    }
  }

  @override
  Future<SuggestedPrice?> suggestPrice({
    required Map<String, dynamic> form,
  }) async {
    final res = await remote.suggestPrice(form);

    if (res.statusCode != 200) return null;

    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final numValue = j['suggested_price'];
    if (numValue == null) return null;

    return SuggestedPrice(
      (numValue as num).toDouble(),
      j['reasoning'] as String?,
    );
  }
}

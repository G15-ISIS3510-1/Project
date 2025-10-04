// import 'dart:convert';
// import 'api_client.dart';
// import '../../models/pricing_model.dart';

// class SuggestedPrice {
//   final double value;
//   final String? reasoning;
//   SuggestedPrice(this.value, this.reasoning);
// }

// class PricingService {
//   static Future<Pricing?> getByVehicle(String vehicleId) async {
//     final res = await Api.get('/api/pricing/vehicle/$vehicleId');
//     if (res.statusCode == 404) return null;
//     if (res.statusCode != 200) {
//       throw Exception('Pricing ${res.statusCode}: ${res.body}');
//     }
//     return Pricing.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
//   }

//   // (Si ya no lo usas, puedes borrar este create.)
//   static Future<Pricing> create(
//     String vehicleId,
//     double dailyPrice, {
//     int minDays = 1,
//     int maxDays = 30,
//     String currency = 'USD',
//   }) async {
//     final res = await Api.post('/api/pricing/', {
//       'vehicle_id': vehicleId,
//       'daily_price': dailyPrice,
//       'min_days': minDays,
//       'max_days': maxDays,
//       'currency': currency,
//     });
//     if (res.statusCode != 201 && res.statusCode != 200) {
//       throw Exception('Create pricing ${res.statusCode}: ${res.body}');
//     }
//     return Pricing.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
//   }

//   static Future<SuggestedPrice?> suggestPrice({
//     required Map<String, dynamic> form,
//   }) async {
//     final res = await Api.post('/api/pricing/suggest', form);
//     if (res.statusCode == 200) {
//       final j = jsonDecode(res.body);
//       return SuggestedPrice(
//         (j['suggested_price'] as num).toDouble(),
//         j['reasoning'] as String?,
//       );
//     }
//     return null;
//   }

//   // ⬇️ CORREGIDO: pasa un Map (sin jsonEncode) y sin parámetro nombrado `body`
//   static Future<void> upsertForVehicle({
//     required String vehicleId,
//     required double dailyPrice,
//     String currency = 'USD',
//   }) async {
//     final res = await Api.post('/api/pricing/vehicle/$vehicleId', {
//       'daily_price': dailyPrice,
//       'currency': currency,
//     });
//     if (res.statusCode != 200 && res.statusCode != 201) {
//       throw Exception('Pricing upsert failed: ${res.statusCode} ${res.body}');
//     }
//   }
// }

import 'package:http/http.dart' as http;
import 'api_client.dart'; // Api.I()

class PricingService {
  Future<http.Response> getByVehicle(String vehicleId) {
    return Api.I().get('/api/pricing/vehicle/$vehicleId');
  }

  Future<http.Response> upsertForVehicle({
    required String vehicleId,
    required double dailyPrice,
    String currency = 'USD',
    int min_days = 1,
    int max_days = 30,
  }) {
    return Api.I().post('/api/pricing/', {
      'vehicle_id': vehicleId,
      'daily_price': dailyPrice,
      'currency': currency,
      'min_days': min_days,
      'max_days': max_days,
    });
  }

  Future<http.Response> suggestPrice(Map<String, dynamic> form) {
    return Api.I().post('/api/pricing/suggest', form);
  }

  // (Opcional) endpoints CRUD si los habilitas en tu backend:
  // Future<http.Response> createRaw(Map<String, dynamic> body) => Api.I().post('/api/pricing/', body);
  // Future<http.Response> putRaw(String id, Map<String, dynamic> body) => Api.I().put('/api/pricing/$id', body);
  // Future<http.Response> deleteRaw(String id) => Api.I().delete('/api/pricing/$id');
}

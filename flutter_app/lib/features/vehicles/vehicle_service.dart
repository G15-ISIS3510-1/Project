import 'dart:convert';
import 'vehicle.dart';
import '../../core/api.dart';

class VehicleService {
  static Future<List<Vehicle>> list() async {
    final res = await Api.get('/api/vehicles/'); // ajusta el path a tu backend
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

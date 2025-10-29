import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/repositories/pricing_repository.dart';
import 'package:flutter_app/data/repositories/vehicle_repository.dart';
import 'package:image_picker/image_picker.dart';

class AddVehicleViewModel extends ChangeNotifier {
  final VehicleRepository vehicles;
  final PricingRepository pricing;

  AddVehicleViewModel({required this.vehicles, required this.pricing});

  bool loading = false;
  bool fetchingSuggest = false;
  bool suggestionStale = false;

  double? suggested;
  String? reason;

  String transmission = 'AT'; // automático
  String fuelType = 'gas';
  String status = 'active';

  void setTransmission(String v) {
    transmission = v;
    markStale();
    notifyListeners();
  }

  void setFuelType(String v) {
    fuelType = v;
    markStale();
    notifyListeners();
  }

  void setStatus(String v) {
    status = v;
    notifyListeners();
  }

  void markStale() {
    if (!suggestionStale) {
      suggestionStale = true;
      notifyListeners();
    }
  }

  Future<void> fetchSuggestedPrice({
    String? make,
    String? model,
    int? year,
    int? seats,
    int? mileage,
    double? lat,
    double? lng,
  }) async {
    final form = <String, dynamic>{};
    void putIf(String k, Object? v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return;
      form[k] = v;
    }

    putIf('make', make?.trim());
    putIf('model', model?.trim());
    putIf('year', year);
    putIf('seats', seats);
    putIf('mileage', mileage);
    putIf('lat', lat);
    putIf('lng', lng);
    putIf('transmission', transmission);
    putIf('fuel_type', fuelType);

    if (form.isEmpty) return;

    fetchingSuggest = true;
    notifyListeners();
    try {
      final res = await pricing.suggestPrice(form: form);
      suggested = res?.value;
      reason = res?.reasoning;
      suggestionStale = false;
    } finally {
      fetchingSuggest = false;
      notifyListeners();
    }
  }

  /// Crea el vehículo y (si hay archivo) sube la foto usando el endpoint:
  ///   /api/vehicles/{vehicle_id}/upload-photo
  /// Flujo:
  ///   1) createVehicle (con imageUrl sólo si se pasó una URL)
  ///   2) si viene imageFile -> uploadVehiclePhoto(vehicleId, file)
  ///   3) upsert de pricing
  Future<bool> submit({
    required String title,
    required String make,
    required String model,
    required int year,
    required String plate,
    required int seats,
    required int mileage,
    required double lat,
    required double lng,
    required double dailyPrice,
    String? imageUrl, // URL directa (opcional)
    XFile? imageFile, // archivo a subir (opcional)
  }) async {
    loading = true;
    notifyListeners();

    try {
      // 1) Crear vehículo primero para obtener vehicleId
      //    - Si el usuario pasó una URL directa, la enviamos en create
      //    - Si hay archivo, NO pasamos imageUrl (la asociamos luego con upload)
      final shouldSendUrlInCreate =
          (imageFile == null) && (imageUrl != null && imageUrl.isNotEmpty);

      final vehicleId = await vehicles.createVehicle(
        title: title,
        make: make,
        model: model,
        year: year,
        transmission: transmission,
        pricePerDay: dailyPrice,
        plate: plate.toUpperCase(),
        seats: seats,
        fuelType: fuelType,
        mileage: mileage,
        status: status,
        lat: lat,
        lng: lng,
        imageUrl: shouldSendUrlInCreate ? imageUrl : null,
      );

      // 2) Si hay archivo, subir foto al endpoint /vehicles/{vehicle_id}/upload-photo
      if (imageFile != null) {
        // Devuelve la URL de la foto (si la necesitas para UI, podrías guardarla)
        await vehicles.uploadVehiclePhoto(
          vehicleId: vehicleId,
          file: imageFile,
        );
      }

      // 3) Guardar pricing
      await pricing.upsertForVehicle(
        vehicleId: vehicleId,
        dailyPrice: dailyPrice,
        currency: 'USD',
        minDays: 1,
        maxDays: 30,
      );

      return true;
    } catch (e) {
      rethrow; // mantenemos el comportamiento original
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

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

  String transmission = 'AT'; 
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
    String? imageUrl,
    XFile? imageFile,
  }) async {
    loading = true;
    notifyListeners();
    try {
      String? finalImageUrl;

      if (imageFile != null) {
        finalImageUrl = await vehicles.uploadVehiclePhoto(file: imageFile);
      } else if (imageUrl != null && imageUrl.isNotEmpty) {
        finalImageUrl = imageUrl;
      }

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
        imageUrl: finalImageUrl,
      );

      await pricing.upsertForVehicle(
        vehicleId: vehicleId,
        dailyPrice: dailyPrice,
        currency: 'USD',
        minDays: 1,
        maxDays: 30,
      );

      return true;
    } catch (_) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
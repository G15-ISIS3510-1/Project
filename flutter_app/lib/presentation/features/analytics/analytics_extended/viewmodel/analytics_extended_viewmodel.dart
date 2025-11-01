import 'package:flutter/foundation.dart';
import '/app/utils/net.dart';
import '../../../../../data/repositories/analytics_repository.dart';

class AnalyticsExtendedViewModel extends ChangeNotifier {
  final AnalyticsRepositoryImpl repository;

  bool loading = false;
  bool usedCache = false; // ← indicador agregado
  List<dynamic> demandPeaks = [];
  String? error;

  AnalyticsExtendedViewModel(this.repository);

  Future<void> fetchDemandPeaksExtended() async {
    loading = true;
    usedCache = false;
    notifyListeners();

    try {
      final isOnline = await Net.isOnline();

      //final result = await repository.getDemandPeaksExtended();
      final result = _mockedData();

      if (result is List) {
        demandPeaks = result;
        if (!isOnline) usedCache = true;
      } else {
        demandPeaks = [];
        error = 'Unexpected response format';
      }

      if (kDebugMode) {
        print('DEMAND PEAKS EXTENDED RESULT: $demandPeaks');
      }

      error = null;
    } catch (e, stack) {
      error = e.toString();
      if (kDebugMode) {
        print('ERROR fetching demand peaks extended: $e');
        print(stack);
      }
      demandPeaks = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _mockedData() {
    return [
      {
        "lat_zone": 4.60,
        "lon_zone": -74.10,
        "hour_slot": 9,
        "make": "Toyota",
        "year": 2020,
        "fuel_type": "gas",
        "transmission": "AT",
        "rentals": 15
      },
      {
        "lat_zone": 4.70,
        "lon_zone": -74.05,
        "hour_slot": 14,
        "make": "Mazda",
        "year": 2019,
        "fuel_type": "diesel",
        "transmission": "MT",
        "rentals": 8
      },
      {
        "lat_zone": 4.65,
        "lon_zone": -74.08,
        "hour_slot": 20,
        "make": "Kia",
        "year": 2021,
        "fuel_type": "electric",
        "transmission": "AT",
        "rentals": 12
      },
      {
        "lat_zone": 4.55,
        "lon_zone": -74.12,
        "hour_slot": 7,
        "make": "Chevrolet",
        "year": 2018,
        "fuel_type": "gas",
        "transmission": "MT",
        "rentals": 10
      },
      {
        "lat_zone": 4.62,
        "lon_zone": -74.11,
        "hour_slot": 18,
        "make": "Renault",
        "year": 2022,
        "fuel_type": "hybrid",
        "transmission": "AT",
        "rentals": 19
      },
      {
        "lat_zone": 4.59,
        "lon_zone": -74.09,
        "hour_slot": 11,
        "make": "Hyundai",
        "year": 2020,
        "fuel_type": "gas",
        "transmission": "CVT",
        "rentals": 7
      },
      {
        "lat_zone": 4.63,
        "lon_zone": -74.07,
        "hour_slot": 15,
        "make": "Nissan",
        "year": 2021,
        "fuel_type": "electric",
        "transmission": "AT",
        "rentals": 21
      },
      {
        "lat_zone": 4.68,
        "lon_zone": -74.02,
        "hour_slot": 8,
        "make": "Ford",
        "year": 2017,
        "fuel_type": "diesel",
        "transmission": "MT",
        "rentals": 6
      },
      {
        "lat_zone": 4.66,
        "lon_zone": -74.06,
        "hour_slot": 19,
        "make": "Volkswagen",
        "year": 2023,
        "fuel_type": "hybrid",
        "transmission": "AT",
        "rentals": 17
      },
      {
        "lat_zone": 4.57,
        "lon_zone": -74.15,
        "hour_slot": 22,
        "make": "Tesla",
        "year": 2022,
        "fuel_type": "electric",
        "transmission": "AT",
        "rentals": 25
      },
    ];
  }

}

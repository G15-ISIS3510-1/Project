import 'package:flutter/material.dart';
import '../../../../../data/repositories/analytics_repository.dart';

class AnalyticsExtendedViewModel extends ChangeNotifier {
  final AnalyticsRepositoryImpl repository;

  bool loading = false;
  List<dynamic> demandPeaks = [];

  AnalyticsExtendedViewModel(this.repository);

  Future<void> fetchDemandPeaksExtended() async {
    loading = true;
    notifyListeners();

    try {
      demandPeaks = await repository.getDemandPeaksExtended();
    } catch (e) {
      demandPeaks = [];
      debugPrint('Error fetching demand peaks extended: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import '../../../../data/repositories/analytics_repository.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsRepositoryImpl repository;

  bool loading = false;
  List<dynamic> data = [];
  String? error;

  AnalyticsViewModel({required this.repository});

  Future<void> loadDemandPeaks() async {
    loading = true;
    notifyListeners();

    try {
      final result = await repository.getDemandPeaks();
      data = result;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
import 'package:flutter/foundation.dart';
import '../../../../../data/repositories/analytics_repository.dart';

class AnalyticsExtendedViewModel extends ChangeNotifier {
  final AnalyticsRepositoryImpl repository;

  bool loading = false;
  List<dynamic> demandPeaks = [];
  String? error;

  AnalyticsExtendedViewModel(this.repository);

  Future<void> fetchDemandPeaksExtended() async {
    loading = true;
    notifyListeners();

    try {
      final result = await repository.getDemandPeaksExtended();

      if (result is List) {
        demandPeaks = result;
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
}

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
      if (result is List) {
        data = result;
      } else {
        data = [];
        error = 'Unexpected response format';
      }
      if (kDebugMode) {
        print('RESULT: $data');
      }
      error = null;
    } catch (e, stack) {
      error = e.toString();
      if (kDebugMode) {
        print('ERROR loading demand peaks: $e');
        print(stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

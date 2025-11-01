import 'package:flutter/foundation.dart';
import '/app/utils/net.dart';
import '../../../../data/repositories/analytics_repository.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsRepositoryImpl repository;
  bool loading = false;
  List<dynamic> data = [];
  String? error;
  bool usedCache = false; // ← agregado

  AnalyticsViewModel({required this.repository});

  Future<void> loadDemandPeaks() async {
    loading = true;
    error = null;
    usedCache = false;
    notifyListeners();

    try {
      final isOnline = await Net.isOnline();
      final result = await repository.getDemandPeaks();

      if (result is List && result.isNotEmpty) {
        data = result;
      } else {
        data = [];
        error = 'No results found from API';
      }

      if (!isOnline) {
        usedCache = true;
        if (kDebugMode) {
          print('⚠️ Using cache data until reconnection');
        }
      }

      if (kDebugMode) {
        print('RESULT (DemandPeaks): $data');
      }
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

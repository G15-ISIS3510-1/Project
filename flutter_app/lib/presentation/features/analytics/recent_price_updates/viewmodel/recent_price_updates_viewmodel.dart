import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/repositories/recent_price_updates_repository.dart';

class RecentPriceUpdatesViewModel extends ChangeNotifier {
  final RecentPriceUpdatesRepository repository;

  RecentPriceUpdatesViewModel({required this.repository});

  bool loading = false;
  String? error;
  double? averagePrice;
  int sampleSize = 0;
  bool usedCache = false;
  DateTime? fetchedAt;

  Future<void> load({bool forceRefresh = false}) async {
    if (loading && !forceRefresh) return;
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result =
          await repository.getAverageDailyPrice(forceRefresh: forceRefresh);
      averagePrice = result.averagePrice;
      sampleSize = result.sampleSize;
      usedCache = result.usedCache;
      fetchedAt = result.fetchedAt;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

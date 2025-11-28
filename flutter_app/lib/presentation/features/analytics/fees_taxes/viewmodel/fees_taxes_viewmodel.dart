import 'package:flutter/foundation.dart';

import '../../../../../data/repositories/fees_taxes_repository.dart';

class FeesTaxesViewModel extends ChangeNotifier {
  final FeesTaxesRepository repository;
  final String userId;
  final bool asHost;

  FeesTaxesViewModel({
    required this.repository,
    required this.userId,
    required this.asHost,
  });

  bool loading = false;
  String? error;
  double? average;
  int sampleSize = 0;
  bool usedCache = false;
  String source = '';
  DateTime? fetchedAt;

  Future<void> load({bool forceRefresh = false}) async {
    if (loading && !forceRefresh) return; // evita cargas dobles
    loading = true;
    error = null;
    notifyListeners();

    try {
      if (userId.isEmpty) {
        average = 0;
        sampleSize = 0;
        usedCache = true;
        source = 'no-user';
        fetchedAt = DateTime.now();
        return;
      }

      final result = await repository.getAverageFeesTaxes(
        userId: userId,
        asHost: asHost,
        forceRefresh: forceRefresh,
      );
      average = result.average;
      sampleSize = result.sampleSize;
      usedCache = result.usedCache;
      source = result.source;
      fetchedAt = result.fetchedAt;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

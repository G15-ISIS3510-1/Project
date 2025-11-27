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
    loading = true;
    error = null;
    notifyListeners();

    try {
      if (userId.isEmpty) {
        throw Exception('No active user session to compute bookings.');
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

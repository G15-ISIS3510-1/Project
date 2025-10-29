import 'package:flutter/material.dart';
import '../../../../../data/repositories/analytics_repository.dart';

class OwnerIncomeViewModel extends ChangeNotifier {
  final AnalyticsRepositoryImpl repository;

  bool loading = false;
  List<dynamic> ownerIncome = [];

  OwnerIncomeViewModel(this.repository);

  Future<void> fetchOwnerIncome() async {
    loading = true;
    notifyListeners();

    try {
      ownerIncome = await repository.getOwnerIncome();
    } catch (e) {
      ownerIncome = [];
      debugPrint('Error fetching owner income: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

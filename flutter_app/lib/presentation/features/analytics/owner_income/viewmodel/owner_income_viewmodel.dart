import 'package:flutter/foundation.dart';
import '../../../../../data/repositories/analytics_repository.dart';

class OwnerIncomeViewModel extends ChangeNotifier {
  final AnalyticsRepositoryImpl repository;

  bool loading = false;
  List<dynamic> ownerIncome = [];
  String? error;

  OwnerIncomeViewModel(this.repository);

  Future<void> fetchOwnerIncome() async {
    loading = true;
    notifyListeners();

    try {
      final result = await repository.getOwnerIncome();

      if (result is List) {
        ownerIncome = result;
      } else {
        ownerIncome = [];
        error = 'Unexpected response format';
      }

      if (kDebugMode) {
        print('OWNER INCOME RESULT: $ownerIncome');
      }

      error = null;
    } catch (e, stack) {
      error = e.toString();
      if (kDebugMode) {
        print('ERROR fetching owner income: $e');
        print(stack);
      }
      ownerIncome = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

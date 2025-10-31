import 'package:flutter/foundation.dart';
import '/app/utils/net.dart';
import '../../../../../data/repositories/analytics_repository.dart';

class OwnerIncomeViewModel extends ChangeNotifier {
  final AnalyticsRepositoryImpl repository;

  bool loading = false;
  List<dynamic> ownerIncome = [];
  String? error;
  bool usedCache = false; // ← añadido

  OwnerIncomeViewModel(this.repository);

  Future<void> fetchOwnerIncome() async {
    loading = true;
    usedCache = false;
    notifyListeners();

    try {
      final isOnline = await Net.isOnline();

      final result = await repository.getOwnerIncome();
      //final result = _mockedData();

      if (result is List) {
        ownerIncome = result;
        if (!isOnline) {
          usedCache = true; // ← marcar uso de cache
        }
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

  List<Map<String, dynamic>> _mockedData() {
    return [
      {"owner_id": "A001", "month": "2025-01", "total_income": 1250000.50},
      {"owner_id": "A002", "month": "2025-01", "total_income": 980000.00},
      {"owner_id": "A003", "month": "2025-01", "total_income": 1640000.75},
      {"owner_id": "A001", "month": "2025-02", "total_income": 1320000.00},
      {"owner_id": "A002", "month": "2025-02", "total_income": 875000.25},
      {"owner_id": "A003", "month": "2025-02", "total_income": 1795000.00},
      {"owner_id": "A001", "month": "2025-03", "total_income": 1410000.00},
      {"owner_id": "A002", "month": "2025-03", "total_income": 910000.75},
      {"owner_id": "A003", "month": "2025-03", "total_income": 1850000.00},
    ];
  }
}

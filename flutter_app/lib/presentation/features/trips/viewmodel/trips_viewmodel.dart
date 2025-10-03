import 'package:flutter/foundation.dart';

class TripsViewModel extends ChangeNotifier {
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  void _setLoading(bool v) {
    if (_loading == v) return;
    _loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  // TODO: inject repository via constructor
  // TODO: expose state and async methods
}

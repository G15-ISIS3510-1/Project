import 'package:flutter/foundation.dart';

class HostModeProvider extends ChangeNotifier {
  bool _isHostMode = false;

  bool get isHostMode => _isHostMode;

  void toggleHostMode() {
    _isHostMode = !_isHostMode;
    notifyListeners();
  }

  void setHostMode(bool value) {
    _isHostMode = value;
    notifyListeners();
  }
}

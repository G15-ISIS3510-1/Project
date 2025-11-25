import 'package:flutter/material.dart';
import '/app/utils/net.dart';
import 'package:flutter/foundation.dart';

class AboutViewModel extends ChangeNotifier {
  bool loading = false;
  bool usedCache = false;
  String? error;

  String version = "1.0.0";
  String lastUpdated = "21/09/2025";
  String aboutText = "";

  String? cachedData;

  Future<void> loadAboutData() async {
    loading = true;
    usedCache = false;
    error = null;
    notifyListeners();

    try {
      final isOnline = await Net.isOnline();

      if (!isOnline) {
        usedCache = true;

        if (cachedData != null) {
          aboutText = cachedData!;
        } else {
          aboutText = "Offline. No cached data available.";
        }

        loading = false;
        notifyListeners();
        return;
      }

      final result = _mockedAboutData();

      aboutText = result;
      cachedData = result;
      error = null;
    } catch (e, stack) {
      error = e.toString();
      if (kDebugMode) {
        print("ERROR ABOUT VIEW: $e");
        print(stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  String _mockedAboutData() {
    return '''
Qovo – About Us

Qovo is a peer-to-peer vehicle rental platform designed to connect car owners with renters safely and seamlessly.

Mission:
- Modernize mobility worldwide.
- Enable anyone to rent a vehicle quickly.
- Empower owners to generate income safely.

Vision:
Shared, transparent, and sustainable mobility.

Values:
- Security
- Transparency
- Fairness
- Innovation
''';
  }
}

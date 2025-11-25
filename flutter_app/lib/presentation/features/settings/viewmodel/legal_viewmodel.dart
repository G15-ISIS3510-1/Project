import 'package:flutter/material.dart';
import '/app/utils/net.dart';
import 'package:flutter/foundation.dart';

class LegalViewModel extends ChangeNotifier {
  bool loading = false;
  bool usedCache = false;
  String? error;

  String legalText = "";
  String? cachedLegalText;

  Future<void> loadLegalData() async {
    loading = true;
    error = null;
    usedCache = false;
    notifyListeners();

    try {
      final isOnline = await Net.isOnline();

      if (!isOnline) {
        usedCache = true;

        if (cachedLegalText != null) {
          legalText = cachedLegalText!;
        } else {
          legalText = "Offline. No cached Terms & Conditions available.";
        }

        loading = false;
        notifyListeners();
        return;
      }

      final result = _mockedTerms();

      legalText = result;
      cachedLegalText = result;
      usedCache = false;
      error = null;
    } catch (e, stack) {
      error = e.toString();
      if (kDebugMode) {
        print("ERROR LOADING TERMS: $e");
        print(stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  String _mockedTerms() {
    return '''
Qovo – Terms and Conditions

Last updated: 21/09/2025

Welcome to Qovo. These Terms and Conditions ("Terms") govern your use of the Qovo mobile application and its related services ("Services"). By accessing or using the Qovo mobile app, you agree to be bound by these Terms. If you do not agree, you must not use the app.

1. Definitions
- "User" means any person who creates an account on the Qovo app.
- "Renter" means a User who books a vehicle.
- "Owner" means a User who lists a vehicle for rent.
- "Vehicle" means any automobile made available for rental.
- "Agreement" refers to these Terms + our Privacy Policy.

2. Eligibility
- Users must be at least 21 years old.
- Renters must hold a valid driver’s license.
- All information provided must be accurate and complete.
''';
  }
}

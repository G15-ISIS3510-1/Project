import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '/app/utils/net.dart';
import '../../analytics/time_analytics/data/time_tracker.dart';
import '../../analytics/time_analytics/data/time_storage.dart';

class ReferralViewModel extends ChangeNotifier {
  bool usedCache = false;
  bool loading = false;
  String? error;

  String referralCode = "";

  ReferralViewModel() {
    loadReferralCode();
  }

  Future<void> loadReferralCode() async {
    loading = true;
    notifyListeners();

    try {
      final online = await Net.isOnline();
      usedCache = !online;

      referralCode = await _generateReferralCode();
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<String> _generateReferralCode() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return "QOVO-${DateTime.now().millisecondsSinceEpoch % 999999}";
  }

  Future<void> copyCode() async {
    await Clipboard.setData(ClipboardData(text: referralCode));
  }

  Future<String> buildShareMessage() async {
    final msg = await compute(_buildMessage, referralCode);
    return msg;
  }
}

String _buildMessage(String code) {
  return """
🚗 Use my QOVO referral code: **$code**

Sign up and get a discount on your first booking!
""";
}

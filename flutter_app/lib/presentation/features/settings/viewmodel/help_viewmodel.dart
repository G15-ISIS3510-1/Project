import 'package:flutter/foundation.dart';
import '../../analytics/time_analytics/data/time_tracker.dart';
import '../../analytics/time_analytics/data/time_storage.dart';
import '/app/utils/net.dart';

class HelpViewModel extends ChangeNotifier {
  bool loading = false;
  bool usedCache = false;
  String? error;

  String faq = "";
  String contact = "";

  Future<void> load() async {
    loading = true;
    notifyListeners();

    try {
      final online = await Net.isOnline();
      usedCache = !online;

      final result = await compute(_process, null);

      faq = result["faq"] ?? "";
      contact = result["contact"] ?? "";

      error = null;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }
}

Map<String, String> _process(void _) {
  return {
    "faq": """
• How do I book a vehicle?
You can browse cars, select one, choose the dates, and confirm your booking.

• What happens if the host cancels?
You will receive an automatic refund and priority assistance.

• How do payments work?
Payments are processed securely using your saved payment method.

• How do I contact support?
You can email us or use in-app help options.
""",
    "contact": """
Email: support@qovo.com
Phone: +1 202 555 0148
Working Hours: 24/7
"""
  };
}

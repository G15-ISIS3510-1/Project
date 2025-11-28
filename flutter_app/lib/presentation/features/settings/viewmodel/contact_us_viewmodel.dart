import 'package:flutter/foundation.dart';
import '../../analytics/time_analytics/data/time_tracker.dart';
import '../../analytics/time_analytics/data/time_storage.dart';
import '/app/utils/net.dart';

class ContactUsViewModel extends ChangeNotifier {
  bool loading = false;
  bool sent = false;
  bool usedCache = false;
  String? error;

  String name = "";
  String email = "";
  String phone = "";
  String subject = "";
  String message = "";

  void setName(String v) {
    name = v;
    notifyListeners();
  }

  void setEmail(String v) {
    email = v;
    notifyListeners();
  }

  void setPhone(String v) {
    phone = v;
    notifyListeners();
  }

  void setSubject(String v) {
    subject = v;
    notifyListeners();
  }

  void setMessage(String v) {
    message = v;
    notifyListeners();
  }

  bool get isValid =>
      name.isNotEmpty &&
      email.isNotEmpty &&
      subject.isNotEmpty &&
      message.isNotEmpty;

  Future<void> send() async {
    if (!isValid) {
      error = "Please fill all required fields.";
      notifyListeners();
      return;
    }

    loading = true;
    notifyListeners();

    try {
      final online = await Net.isOnline();
      usedCache = !online;

      final formatted = await compute(_formatForm, {
        "name": name,
        "email": email,
        "phone": phone,
        "subject": subject,
        "message": message,
      });

      await Future.delayed(const Duration(seconds: 1));

      sent = true;
      error = null;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }
}

String _formatForm(Map<String, String> data) {
  return """
Name: ${data["name"]}
Email: ${data["email"]}
Phone: ${data["phone"]}
Subject: ${data["subject"]}

Message:
${data["message"]}
""";
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FeedbackRepository {
  final String? apiBase;

  FeedbackRepository({this.apiBase});

  Future<bool> submitFeedback({
    required int rating,
    required String comment,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (apiBase != null) {
      try {
        final res = await http.post(
          Uri.parse('$apiBase/feedback'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "rating": rating,
            "comment": comment,
            "created_at": DateTime.now().toIso8601String(),
          }),
        );

        if (res.statusCode == 200 || res.statusCode == 201) {
          return true;
        }
      } catch (_) {}
    }

    final pending = prefs.getStringList("pending_feedback") ?? [];
    pending.add(jsonEncode({
      "rating": rating,
      "comment": comment,
      "created_at": DateTime.now().toIso8601String(),
    }));
    await prefs.setStringList("pending_feedback", pending);
    return true;
  }

  Future<List<Map<String, dynamic>>> loadPending() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("pending_feedback") ?? [];
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<void> clearPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("pending_feedback");
  }
}

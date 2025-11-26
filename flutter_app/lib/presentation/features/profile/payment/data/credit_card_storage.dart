import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CreditCardStorage {
  static const _key = "saved_credit_cards";

  static Future<List<Map<String, String>>> load() async {
    final prefs = await SharedPreferences.getInstance();

    dynamic raw = prefs.get(_key);

    if (raw == null) {
      return [];
    }

    if (raw is List<String>) {
      return raw.map((jsonStr) {
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        return {
          "number": decoded["number"].toString(),
          "holder": decoded["holder"].toString(),
          "exp": decoded["exp"].toString(),
          "cvv": decoded["cvv"].toString(),
        };
      }).toList();
    }

    if (raw is String) {
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          final converted = decoded.map((e) {
            final map = e as Map<String, dynamic>;
            return {
              "number": map["number"].toString(),
              "holder": map["holder"].toString(),
              "exp": map["exp"].toString(),
              "cvv": map["cvv"].toString(),
            };
          }).toList();

          await save(converted);
          return converted;
        }
      } catch (_) {}
    }

    await prefs.remove(_key);
    return [];
  }

  static Future<void> save(List<Map<String, String>> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = cards.map((c) => json.encode(c)).toList();
    await prefs.setStringList(_key, encoded);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

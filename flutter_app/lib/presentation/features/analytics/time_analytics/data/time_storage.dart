import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TimeStorage {
  static const _key = 'usage_logs';

  static Future<void> save(Map<String, dynamic> record) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(record));
    await prefs.setStringList(_key, list);
  }

  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => jsonDecode(e)).cast<Map<String, dynamic>>().toList();
  }
}

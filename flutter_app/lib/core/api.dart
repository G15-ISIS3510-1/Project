import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Api {
  Api._();
  static final storage = const FlutterSecureStorage();
  static final String base = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:8000', // emulador Android
  );

  static Future<http.Response> get(String path) async {
    final t = await storage.read(key: 'access_token');
    return http.get(
      Uri.parse('$base$path'),
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t',
      },
    );
  }

  static Future<http.Response> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final t = await storage.read(key: 'access_token');
    return http.post(
      Uri.parse('$base$path'),
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t',
      },
      body: jsonEncode(body),
    );
  }
}

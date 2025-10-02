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

// PROPOSED API.DART FOR SINGLETON PATTERN
// lib/core/api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// API client as a Singleton.
/// - Configure once (base URL + token) and reuse everywhere via Api.I().
/// - Call Api.I().setToken(token) after login; Api.I().setToken(null) on logout.
/// - You can also call Api.I().loadTokenFromStorage() if you keep tokens in
///   FlutterSecureStorage and want to bootstrap on app start.
// class Api {
//   // -------- Singleton plumbing --------
//   Api._internal(this._base);
//   static Api? _instance;
//   static Api I() => _instance ??= Api._internal(_normalize(_defaultBase));

//   // Default base from --dart-define=API_BASE (or emulator fallback)
//   static final String _defaultBase = const String.fromEnvironment(
//     'API_BASE',
//     defaultValue: 'http://10.0.2.2:8000',
//   );

//   // -------- State --------
//   String _base; // e.g. http://10.0.2.2:8000 (no trailing slash)
//   String? _token;

//   // Optional secure storage bootstrap
//   static const FlutterSecureStorage _storage = FlutterSecureStorage();

//   // -------- Public configuration --------
//   /// Set/override API base (trailing slash removed automatically).
//   void setBase(String base) => _base = _normalize(base);

//   /// Set or clear bearer token.
//   void setToken(String? token) => _token = token;

//   /// Load token from secure storage (default key: 'access_token').
//   Future<void> loadTokenFromStorage({String key = 'access_token'}) async {
//     _token = await _storage.read(key: key);
//   }

//   // Expose for callers that need them
//   String get baseUrl => _base;
//   Map<String, String> get authHeaders => {
//         'Content-Type': 'application/json',
//         if (_token != null) 'Authorization': 'Bearer $_token',
//       };

//   // -------- HTTP helpers --------
//   Future<http.Response> get(String path) {
//     return http.get(Uri.parse('$_base$path'), headers: authHeaders);
//   }

//   Future<http.Response> post(String path, Map<String, dynamic> body) {
//     return http.post(
//       Uri.parse('$_base$path'),
//       headers: authHeaders,
//       body: jsonEncode(body),
//     );
//   }

//   // Optional extra verbs if you need them later
//   Future<http.Response> put(String path, Map<String, dynamic> body) {
//     return http.put(
//       Uri.parse('$_base$path'),
//       headers: authHeaders,
//       body: jsonEncode(body),
//     );
//   }

//   Future<http.Response> delete(String path) {
//     return http.delete(Uri.parse('$_base$path'), headers: authHeaders);
//   }

//   // -------- Utils --------
//   static String _normalize(String url) =>
//       url.endsWith('/') ? url.substring(0, url.length - 1) : url;
// }

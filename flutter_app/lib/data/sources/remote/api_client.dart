// lib/core/api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Api {
  Api._internal(this._base);
  static Api? _instance;
  static Api I() => _instance ??= Api._internal(_normalize(_defaultBase));

  // Lee de --dart-define si lo pasas en build/run
  static final String _defaultBase = 'https://qovo-api-gfa6drobhq-uc.a.run.app';

  String _base;
  String? _token;

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  void setBase(String base) => _base = _normalize(base);
  void setToken(String? token) =>
      _token = (token?.isNotEmpty ?? false) ? token : null;

  Future<void> loadTokenFromStorage({String key = 'access_token'}) async {
    _token = await _storage.read(key: key);
  }

  String get baseUrl => _base;
  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Uri _url(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_base$p');
  }

  Future<http.Response> get(String path) =>
      http.get(_url(path), headers: authHeaders);
  Future<http.Response> post(String path, Map<String, dynamic> body) =>
      http.post(_url(path), headers: authHeaders, body: jsonEncode(body));
  Future<http.Response> put(String path, Map<String, dynamic> body) =>
      http.put(_url(path), headers: authHeaders, body: jsonEncode(body));
  Future<http.Response> delete(String path) =>
      http.delete(_url(path), headers: authHeaders);

  static String _normalize(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;
}

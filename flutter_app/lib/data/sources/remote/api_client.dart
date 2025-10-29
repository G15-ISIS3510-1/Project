// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//
class Api {
  // -------- Singleton plumbing --------
  Api._internal(this._base);
  static Api? _instance;
  static Api I() => _instance ??= Api._internal(_normalize(_defaultBase));

  // Default base from --dart-define=API_BASE (or emulator fallback)
  static final String _defaultBase = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://qovo-api-862569067561.us-central1.run.app',
  );

  // -------- State --------
  String _base; // e.g. https://... (sin trailing slash)
  String? _token;

  String? get token => _token;

  // HTTP client w/ keep-alive control
  IOClient? _client;

  // secure storage to optionally load tokens
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // -------- Public configuration --------
  void setBase(String base) => _base = _normalize(base);
  void setToken(String? token) => _token = token;

  Future<void> loadTokenFromStorage({String key = 'access_token'}) async {
    _token = await _storage.read(key: key);
  }

  String get baseUrl => _base;

  Map<String, String> get authHeaders => {
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
    // Mitiga sockets viejos reutilizados:
    'Connection': 'close',
    'Content-Type': 'application/json',
  };

  // -------- Lifecycle --------
  void close() {
    try {
      _client?.close();
    } catch (_) {}
    _client = null;
  }

  IOClient _ensureClient() {
    _client ??= IOClient(
      HttpClient()
        ..idleTimeout = const Duration(seconds: 10)
        ..connectionTimeout = const Duration(seconds: 12)
        ..autoUncompress = true,
    );
    return _client!;
  }

  // -------- HTTP --------
  Future<http.Response> get(String path) async {
    final uri = Uri.parse('$_base$path');
    try {
      return await _ensureClient().get(uri, headers: authHeaders);
    } on http.ClientException catch (e) {
      final msg = e.toString();
      if (msg.contains('Broken pipe') || msg.contains('Connection reset')) {
        close();
        return await _ensureClient().get(uri, headers: authHeaders);
      }
      rethrow;
    } on SocketException {
      close();
      return await _ensureClient().get(uri, headers: authHeaders);
    }
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_base$path');
    try {
      return await _ensureClient().post(
        uri,
        headers: authHeaders,
        body: jsonEncode(body),
      );
    } on http.ClientException catch (e) {
      final msg = e.toString();
      if (msg.contains('Broken pipe') || msg.contains('Connection reset')) {
        close();
        return await _ensureClient().post(
          uri,
          headers: authHeaders,
          body: jsonEncode(body),
        );
      }
      rethrow;
    } on SocketException {
      close();
      return await _ensureClient().post(
        uri,
        headers: authHeaders,
        body: jsonEncode(body),
      );
    }
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) {
    return _ensureClient().put(
      Uri.parse('$_base$path'),
      headers: authHeaders,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path) {
    return _ensureClient().delete(
      Uri.parse('$_base$path'),
      headers: authHeaders,
    );
  }

  // -------- Utils --------
  static String _normalize(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;
}

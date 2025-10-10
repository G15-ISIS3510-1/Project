// lib/data/sources/remote/auth_remote_source.dart
import 'dart:convert';

import 'package:flutter_app/data/sources/remote/api_client.dart';

class AuthService {
  final _api = Api.I();

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    if (res.statusCode != 200) {
      throw Exception('Login ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = (data['access_token'] as String?)?.trim() ?? '';
    if (token.isEmpty) throw Exception('No llegó access_token del backend');
    return token;
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _api.get('/api/auth/me'); // Authorization via Api.I()
    if (res.statusCode != 200) {
      throw Exception('GET /me ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<_RegisterResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String role,
  }) async {
    final res = await _api.post('/api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
    });
    return _RegisterResult(res.statusCode, res.body);
  }
}

class _RegisterResult {
  final int code;
  final String body;
  _RegisterResult(this.code, this.body);
}

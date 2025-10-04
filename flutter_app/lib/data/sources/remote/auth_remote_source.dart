import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;
  AuthService({required this.baseUrl});

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw Exception('Login ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = (data['access_token'] as String?) ?? '';
    if (token.isEmpty) throw Exception('No llegó access_token del backend');
    return token;
  }

  Future<Map<String, dynamic>> me({required String token}) async {
    final url = Uri.parse('$baseUrl/api/auth/me');
    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) {
      throw Exception('Token inválido: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<_RegisterResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String role, // 'renter' | 'host'
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/register');
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
    };
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _RegisterResult(res.statusCode, res.body);
  }
}

// Simple DTO para mantener semántica de tus status codes
class _RegisterResult {
  final int code;
  final String body;
  _RegisterResult(this.code, this.body);
}

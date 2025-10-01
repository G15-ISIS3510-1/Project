import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/vehicles/vehicle_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_app/Home/app_shell.dart';
import 'package:flutter_app/LoginRegister/register.dart';
import 'package:flutter_app/data/chat_api.dart'; // 👈 importa ChatApi

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  final String baseUrl = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:8000',
  );

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _snack('Por favor llena email y password');
      return;
    }

    setState(() => _loading = true);
    try {
      final url = Uri.parse(
        '$baseUrl/api/auth/login',
      ); // 👈 asegúrate del prefijo
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final token = data['access_token'] as String?;
        if (token == null || token.isEmpty) {
          _snack('No llegó access_token del backend');
          setState(() => _loading = false);
          return;
        }

        await _storage.write(key: 'access_token', value: token);
        VehicleService.token = token;

        // 👇 Verifica identidad y toma user_id
        final meUrl = Uri.parse('$baseUrl/api/auth/me');
        final meRes = await http.get(
          meUrl,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (meRes.statusCode == 200) {
          final me = jsonDecode(meRes.body) as Map<String, dynamic>;
          // Ajusta el campo según tu /me (user_id, id, uid, etc.)
          final userId = me['user_id'] as String?;
          if (userId == null || userId.isEmpty) {
            _snack('No se pudo determinar user_id desde /me');
            setState(() => _loading = false);
            return;
          }

          final api = ChatApi(baseUrl: '$baseUrl/api', token: token);
          //                 ^^^^^^^^^^^^^^^^ si tus routers tienen prefijo /api

          _snack('¡Bienvenido!');
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AppShell(
                api: api,
                currentUserId: userId,
                initialIndex: 0, // Home por defecto
              ),
            ),
          );
        } else {
          _snack('Token inválido: ${meRes.statusCode} ${meRes.body}');
        }
      } else {
        _snack('Login ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      _snack('Error de red: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Transform.scale(
                  scaleY: 0.82,
                  scaleX: 1.0,
                  child: const Text(
                    'QOVO',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      letterSpacing: -7.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              const Text(
                'Login to your account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _loading ? 'Ingresando…' : 'Sign in',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 120),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color(0xFF4C75FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

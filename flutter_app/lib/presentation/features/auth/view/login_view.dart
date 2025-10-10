// lib/presentation/features/auth/view/login_view.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/sources/remote/api_client.dart';
import 'package:flutter_app/data/sources/remote/vehicle_remote_source.dart';
import 'package:flutter_app/presentation/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/presentation/features/app_shell/view/app_shell.dart';
import 'package:flutter_app/presentation/features/auth/view/register_view.dart';
import 'package:flutter_app/data/sources/remote/chat_remote_source.dart'; // ChatApi
import 'package:flutter_app/main.dart' show AuthProvider;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _dec(BuildContext context, String hint) {
    final t = Theme.of(context);
    final fill = t.colorScheme.surfaceVariant.withOpacity(
      t.brightness == Brightness.dark ? 0.3 : 1.0,
    );
    final onSurface = t.colorScheme.onSurface.withOpacity(0.12);
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(color: t.colorScheme.onSurface.withOpacity(0.6)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: onSurface, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: onSurface, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: t.colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Future<void> _handleLogin() async {
    final vm = context.read<AuthViewModel>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _snack('Por favor llena email y password');
      return;
    }

    final ok = await vm.login(email: email, password: password);
    if (!mounted) return;

    if (!ok) {
      _snack(vm.error ?? 'Error al iniciar sesión');
      return;
    }

    final token = vm.token!;
    final userId = vm.userId!;
    // Guarda token de forma central si lo necesitas en otros services
    Api.I().setToken(token);

    await context.read<AuthViewModel>().saveToken(token);

    // Notifica a tu AuthProvider
    context.read<AuthProvider>().signIn(userId: userId, token: token);

    _snack('¡Bienvenido!');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AppShell(
          // si AppShell espera un cliente, pasa Api.I(); si no, bórralo
          currentUserId: userId,
          initialIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final onBg = t.colorScheme.onBackground;
    final loading = context.watch<AuthViewModel>().loading;

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
                  child: Text(
                    'QOVO',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w600,
                      color: onBg,
                      letterSpacing: -7.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Text(
                'Login to your account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: t.colorScheme.onBackground.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: t.colorScheme.onSurface),
                decoration: _dec(context, 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: t.colorScheme.onSurface),
                decoration: _dec(context, 'Password'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: loading ? null : _handleLogin,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    loading ? 'Ingresando…' : 'Sign in',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 120),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: t.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      context.read<AuthViewModel>().reset();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: t.colorScheme.primary,
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/LoginRegister/login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final String baseUrl = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:8000',
  );

  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _passwordC = TextEditingController();

  // 👇 estado para el rol (renter por defecto)
  String _role = 'renter';

  bool _loading = false;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _passwordC.dispose();
    super.dispose();
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
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: onSurface),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: onSurface),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: t.colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final url = Uri.parse('$baseUrl/api/auth/register');

      // Para evitar email duplicado en pruebas (opcional):
      final uniq = DateTime.now().millisecondsSinceEpoch;
      final email = _emailC.text.trim().isEmpty
          ? 'user$uniq@mail.com'
          : _emailC.text.trim();

      final body = {
        'name': _nameC.text.trim(),
        'email': email,
        'password': _passwordC.text,
        'phone': _phoneC.text.trim().isEmpty ? null : _phoneC.text.trim(),
        'role': _role, // 'renter' | 'host'
      };

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (!mounted) return;
      if (res.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Registro exitoso')));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else if (res.statusCode == 200) {
        // upgraded_to_both
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tu cuenta ahora es BOTH (renter + host)'),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else if (res.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya estás registrado con ese rol. Inicia sesión.'),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error ${res.statusCode}: ${res.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Error de red: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 100.0),
                Center(
                  child: Text(
                    'QOVO',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w600,
                      color: t.colorScheme.onBackground,
                      letterSpacing: -6.0,
                    ),
                  ),
                ),
                const SizedBox(height: 50.0),
                Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: t.colorScheme.onBackground.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20.0),

                TextFormField(
                  controller: _nameC,
                  style: TextStyle(color: t.colorScheme.onSurface),
                  decoration: _dec(context, 'Name'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nombre requerido'
                      : null,
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _emailC,
                  style: TextStyle(color: t.colorScheme.onSurface),
                  decoration: _dec(context, 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _phoneC,
                  style: TextStyle(color: t.colorScheme.onSurface),
                  decoration: _dec(context, 'Phone (optional)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16.0),

                TextFormField(
                  controller: _passwordC,
                  style: TextStyle(color: t.colorScheme.onSurface),
                  decoration: _dec(context, 'Password'),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mínimo 6 caracteres'
                      : null,
                ),
                const SizedBox(height: 16.0),

                // 👇 Selector de rol
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: _dec(context, 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'renter', child: Text('Renter')),
                    DropdownMenuItem(value: 'host', child: Text('Host')),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? 'renter'),
                ),

                const SizedBox(height: 24.0),

                FilledButton(
                  onPressed: _loading ? null : _register,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    _loading ? 'Registrando…' : 'Register',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Have an account? ',
                      style: TextStyle(
                        fontSize: 16,
                        color: t.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: t.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

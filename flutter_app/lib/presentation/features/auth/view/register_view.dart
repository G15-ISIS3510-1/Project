import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/presentation/features/auth/view/login_view.dart';

class RegisterDTO {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String role;

  RegisterDTO(this.name, this.email, this.password, this.phone, this.role);

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        'role': role,
      };
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final String baseUrl = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://qovo-api-862569067561.us-central1.run.app',
  );

  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _passwordC = TextEditingController();

  String _role = 'renter';

  final ValueNotifier<bool> _loadingVN = ValueNotifier(false);

  late InputDecoration decName;
  late InputDecoration decEmail;
  late InputDecoration decPhone;
  late InputDecoration decPass;
  late InputDecoration decRole;

  @override
  void initState() {
    super.initState();
    final ctx = WidgetsBinding.instance.renderViewElement!;
    decName = _dec(ctx, 'Name');
    decEmail = _dec(ctx, 'Email');
    decPhone = _dec(ctx, 'Phone (optional)');
    decPass = _dec(ctx, 'Password');
    decRole = _dec(ctx, 'Role');
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    _passwordC.dispose();
    _loadingVN.dispose();
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
    _loadingVN.value = true;

    try {
      final url = Uri.parse('$baseUrl/api/auth/register');

      final uniq = DateTime.now().millisecondsSinceEpoch;
      final email = _emailC.text.trim().isEmpty
          ? 'user$uniq@mail.com'
          : _emailC.text.trim();

      final dto = RegisterDTO(
        _nameC.text.trim(),
        email,
        _passwordC.text,
        _phoneC.text.trim().isEmpty ? null : _phoneC.text.trim(),
        _role,
      );

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dto.toJson()),
      );

      if (!mounted) return;

      if (res.statusCode == 201 || res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else if (res.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role already registered')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ${res.statusCode}: ${res.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network Error: $e')),
      );
    } finally {
      _loadingVN.value = false;
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
              children: [
                const SizedBox(height: 100),
                Text('QOVO', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 50),

                TextFormField(controller: _nameC, decoration: decName),
                const SizedBox(height: 16),

                TextFormField(
                    controller: _emailC,
                    decoration: decEmail,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),

                TextFormField(
                    controller: _phoneC,
                    decoration: decPhone,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordC,
                  obscureText: true,
                  decoration: decPass,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField(
                  value: _role,
                  decoration: decRole,
                  items: const [
                    DropdownMenuItem(value: 'renter', child: Text('Renter')),
                    DropdownMenuItem(value: 'host', child: Text('Host')),
                  ],
                  onChanged: (v) => setState(() => _role = v!),
                ),
                const SizedBox(height: 24),

                ValueListenableBuilder<bool>(
                  valueListenable: _loadingVN,
                  builder: (_, loading, __) {
                    return FilledButton(
                      onPressed: loading ? null : _register,
                      child:
                          Text(loading ? 'Registrando…' : 'Register'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

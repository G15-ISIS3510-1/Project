// lib/settings/profile_settings_view.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Profile/visited_places.dart';
import '../../LoginRegister/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../host_mode_provider.dart';

class UserProfile {
  final String name;
  final String email;
  final String? phone;

  const UserProfile({required this.name, required this.email, this.phone});

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    // Ajusta los campos según tu /me (ejemplos típicos abajo)
    return UserProfile(
      name: (j['name'] ?? j['full_name'] ?? j['username'] ?? '').toString(),
      email: (j['email'] ?? '').toString(),
      phone: j['phone']?.toString(),
    );
  }
}

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  static const _storage = FlutterSecureStorage();
  final String baseUrl = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:8000',
  );

  late Future<UserProfile> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = _fetchProfile();
  }

  Future<UserProfile> _fetchProfile() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No hay access_token. Inicia sesión nuevamente.');
    }

    final uri = Uri.parse(
      '$baseUrl/api/auth/me',
    ); // ajusta si tu ruta es distinta
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return UserProfile.fromJson(data);
    } else if (res.statusCode == 401) {
      // token inválido/expirado: limpiamos y mandamos a login
      await _signOut(context, showMessage: false);
      throw Exception('Sesión expirada. Vuelve a iniciar sesión.');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<void> _signOut(BuildContext context, {bool showMessage = true}) async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');

    if (context.mounted) {
      // opcional: resetear Host Mode
      try {
        context.read<HostModeProvider>().setHostMode(false);
      } catch (_) {}
    }

    if (context.mounted) {
      if (showMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double p24 = 24;

    Widget pillButton(IconData icon, String label, {VoidCallback? onTap}) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap ?? () {},
          icon: Icon(icon, size: 18, color: Colors.black87),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            elevation: 0,
          ),
        ),
      );
    }

    final outlineNeutral = OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: const BorderSide(color: Color(0xFFE5E7EB)),
      padding: const EdgeInsets.symmetric(vertical: 12),
      textStyle: const TextStyle(fontSize: 14),
      foregroundColor: Colors.black87,
    );

    final outlineDestructive = OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: const BorderSide(color: Color(0xFFEE5A5A)),
      padding: const EdgeInsets.symmetric(vertical: 12),
      textStyle: const TextStyle(fontSize: 14),
      foregroundColor: const Color(0xFFEE5A5A),
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(p24, p24, p24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Divider(thickness: 2, color: Colors.black87),
                    const SizedBox(height: 16),

                    // ======= Perfil dinámico =======
                    FutureBuilder<UserProfile>(
                      future: _futureProfile,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Row(
                            children: [
                              const Expanded(child: _ProfileSkeleton()),
                              const SizedBox(width: 12),
                              _AvatarBox(),
                            ],
                          );
                        }
                        if (snap.hasError) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No se pudo cargar el perfil',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                snap.error.toString(),
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () => setState(
                                  () => _futureProfile = _fetchProfile(),
                                ),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          );
                        }
                        final p = snap.data!;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name.isEmpty ? 'Usuario' : p.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    p.phone ?? '—',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.email,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const _AvatarBox(),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ======= Botones =======
                    pillButton(Icons.directions_car_filled_rounded, 'Add Car'),
                    const SizedBox(height: 16),
                    pillButton(
                      Icons.place_outlined,
                      'Visited Places',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const VisitedPlacesScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    pillButton(
                      Icons.notifications_none_rounded,
                      'Communications',
                    ),
                    const SizedBox(height: 16),
                    pillButton(Icons.credit_card_rounded, 'Payment'),

                    const SizedBox(height: 16),
                    const Divider(thickness: 2, color: Colors.black87),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _signOut(context),
                        style: outlineDestructive,
                        child: const Text('Sign Out'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 92)),
          ],
        ),
      ),
    );
  }
}

class _AvatarBox extends StatelessWidget {
  const _AvatarBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2B2B2B), width: 3),
      ),
      child: const Icon(Icons.image, size: 28, color: Colors.black87),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget box({double h = 14, double w = 160}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box(h: 18, w: 180),
        const SizedBox(height: 8),
        box(w: 120),
        const SizedBox(height: 6),
        box(w: 200),
      ],
    );
  }
}

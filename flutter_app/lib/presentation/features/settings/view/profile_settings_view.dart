import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/analytics_repository.dart';
import 'package:flutter_app/data/sources/remote/analytics_remote_source.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/presentation/features/analytics/view/analytics_view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/data/repositories/vehicle_repository.dart';
import 'package:flutter_app/data/repositories/pricing_repository.dart';
import 'package:flutter_app/presentation/features/vehicle/viewmodel/add_vehicle_viewmodel.dart';
import 'package:flutter_app/presentation/features/booking_reminders/view/booking_reminders_view.dart';
import '../../profile/view/visited_places_view.dart';
import '../../auth/view/login_view.dart';
import '../../app_shell/viewmodel/host_mode_provider.dart';
import 'package:flutter_app/presentation/features/vehicle/view/add_vehicle_view.dart';
import 'package:flutter_app/presentation/features/analytics/view/analytics_view.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    return UserProfile(
      id: (j['id'] ?? j['_id'] ?? j['user_id'] ?? j['email']).toString(),
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
    defaultValue: 'https://qovo-api-862569067561.us-central1.run.app',
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

    final uri = Uri.parse('$baseUrl/api/auth/me');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return UserProfile.fromJson(data);
    } else if (res.statusCode == 401) {
      await _signOut(showMessage: false);
      throw Exception('Sesión expirada. Vuelve a iniciar sesión.');
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }

  Future<void> _signOut({bool showMessage = true}) async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');

    if (!mounted) return;

    try {
      context.read<HostModeProvider>().setHostMode(false);
    } catch (_) {}

    if (mounted) {
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    Widget pillButton(IconData icon, String label, {VoidCallback? onTap}) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap ?? () {},
          icon: Icon(icon, size: 18, color: scheme.onSurface),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              label,
              style: text.bodyLarge?.copyWith(color: scheme.onSurface),
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: theme.cardColor,
            overlayColor: scheme.primary.withOpacity(0.06),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: scheme.outlineVariant),
            elevation: 0,
          ),
        ),
      );
    }

    final outlineNeutral = OutlinedButton.styleFrom(
      backgroundColor: theme.cardColor,
      overlayColor: scheme.primary.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: scheme.outlineVariant),
      padding: const EdgeInsets.symmetric(vertical: 12),
      textStyle: text.bodyMedium,
      foregroundColor: scheme.onSurface,
    );

    final outlineDestructive = OutlinedButton.styleFrom(
      backgroundColor: theme.cardColor,
      overlayColor: scheme.error.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: scheme.error),
      padding: const EdgeInsets.symmetric(vertical: 12),
      textStyle: text.bodyMedium,
      foregroundColor: scheme.error,
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
                      icon: Icon(Icons.close, color: scheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Settings',
                      style: text.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(thickness: 2, color: scheme.outlineVariant),
                    const SizedBox(height: 16),
                    FutureBuilder<UserProfile>(
                      future: _futureProfile,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Row(
                            children: const [
                              Expanded(child: _ProfileSkeleton()),
                              SizedBox(width: 12),
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
                                style: text.bodyMedium?.copyWith(
                                  color: scheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                snap.error.toString(),
                                style: text.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () => setState(
                                  () => _futureProfile = _fetchProfile(),
                                ),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                                style: outlineNeutral,
                              ),
                            ],
                          );
                        }
                        final p = snap.data;
                        if (p == null) {
                          return const Text('El perfil no se pudo cargar.');
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name.isEmpty ? 'Usuario' : p.name,
                                    style: text.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    p.phone ?? '—',
                                    style: text.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.email,
                                    style: text.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
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
                    pillButton(
                      Icons.directions_car_filled_rounded,
                      'Add Car',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (ctx) => AddVehicleViewModel(
                                vehicles: ctx.read<VehicleRepository>(),
                                pricing: ctx.read<PricingRepository>(),
                              ),
                              child: const AddVehicleView(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    pillButton(
                      Icons.place_outlined,
                      'Visited Places',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const VisitedPlacesView(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    pillButton(
                      Icons.bar_chart_rounded,
                      'Rental Zones',
                      onTap: () {
                        final repository = AnalyticsRepositoryImpl(
                          remoteSource: AnalyticsRemoteSourceImpl(
                            client: http.Client(),
                            baseUrl: kApiBase,
                          ),
                        );

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AnalyticsView(repository: repository),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    pillButton(
                      Icons.access_time,
                      'Booking Reminders',
                      onTap: () async {
                        try {
                          final user = await _futureProfile;
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookingRemindersView(userId: user.id),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pudo obtener el perfil de usuario.',
                                ),
                              ),
                            );
                          }
                        }
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
                    Divider(thickness: 2, color: scheme.outlineVariant),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _signOut(),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline, width: 3),
      ),
      child: Icon(Icons.image, size: 28, color: scheme.onSurface),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget box({double h = 14, double w = 160}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
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

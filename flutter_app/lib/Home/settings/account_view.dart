// lib/settings/account_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../host_mode_provider.dart';

import 'profile_settings_view.dart';
import 'currency_view.dart';
import 'legal_view.dart';

// 👇 importa tus providers/apis reales
import '../../data/users_api.dart';
import '../../LoginRegister/register.dart';
import '../../main.dart' show AuthProvider;

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  Future<void> _handleHostToggle(BuildContext context, bool value) async {
    final hostProvider = context.read<HostModeProvider>();

    // Apagar host mode: inmediato.
    if (!value) {
      hostProvider.setHostMode(false);
      return;
    }

    final auth = Provider.of<AuthProvider?>(context, listen: false);
    final usersApi = Provider.of<UsersApi?>(context, listen: false);
    final userId = auth?.userId;

    if (usersApi == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para activar Host Mode.')),
      );
      return;
    }

    // 1) Intento con caché, 2) si viene null, forzar refresh.
    String? role = await usersApi.getUserRole(userId);
    role ??= await usersApi.getUserRole(userId, refresh: true);

    if (role == 'host' || role == 'both') {
      hostProvider.setHostMode(true);
      return;
    } else {
      hostProvider.setHostMode(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa el registro como host para activar el modo Host.',
          ),
        ),
      );
    }

    // role es 'renter' o null -> mandar a registro de host.
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );

    // Al volver, refrescar rol y decidir.
    role = await usersApi.getUserRole(userId, refresh: true);
    if (role == 'host' || role == 'both') {
      hostProvider.setHostMode(true);
    } else {
      hostProvider.setHostMode(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa el registro como host para activar el modo Host.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double p24 = 24;
    const double p16 = 16;

    final isHost = context.watch<HostModeProvider>().isHostMode;

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

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(p24, p24, p24, p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Transform.scale(
                      scaleY: 0.82,
                      child: const Text(
                        'QOVO',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          letterSpacing: -7.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Host Mode toggle con validación de rol
                  Consumer<HostModeProvider>(
                    builder: (context, hostProvider, _) {
                      return SwitchListTile.adaptive(
                        title: const Text(
                          'Host Mode',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        value: hostProvider.isHostMode,
                        onChanged: (value) {
                          // Ejecutar flujo async sin bloquear el UI thread
                          _handleHostToggle(context, value);
                        },
                        activeThumbColor: Colors.green,
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),

                  if (isHost) ...[
                    const Center(
                      child: Text(
                        'Host mode is ON',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 16),

                  // Botones tipo "pill"
                  pillButton(
                    Icons.settings,
                    'Settings',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileSettingsView(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  pillButton(
                    Icons.currency_pound,
                    'Currency',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CurrencyView()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  pillButton(
                    Icons.info_outline,
                    'Legal',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LegalView()),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'v.3686.1000',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Espacio inferior para la bottom bar
          const SliverToBoxAdapter(child: SizedBox(height: 92)),
        ],
      ),
    );
  }
}

// lib/settings/account_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../host_mode_provider.dart';

import 'profile_settings_view.dart';
import 'currency_view.dart';
import 'legal_view.dart';

import '../../data/users_api.dart';
import '../../LoginRegister/register.dart';
import '../../main.dart' show AuthProvider;
import '../../core/theme_controller.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  Future<void> _handleHostToggle(BuildContext context, bool value) async {
    final hostProvider = context.read<HostModeProvider>();

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

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );

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

    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final isHost = context.watch<HostModeProvider>().isHostMode;
    final themeCtrl = context.watch<ThemeController>();

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
            backgroundColor: scheme.surface,
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
                      child: Text(
                        'QOVO',
                        style: text.displaySmall?.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          color: scheme.onBackground.withOpacity(0.95),
                          letterSpacing: -7.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Host Mode toggle
                  Consumer<HostModeProvider>(
                    builder: (context, hostProvider, _) {
                      return SwitchListTile.adaptive(
                        title: Text(
                          'Host Mode',
                          style: text.bodyLarge?.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        value: hostProvider.isHostMode,
                        onChanged: (value) => _handleHostToggle(context, value),
                        activeColor: scheme.primary,
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),

                  if (isHost) ...[
                    Center(
                      child: Text(
                        'Host mode is ON',
                        style: text.titleMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 8),

                  // Appearance
                  Text(
                    'Appearance',
                    style: text.titleMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Card(
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: scheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme',
                            style: text.bodyMedium?.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<ThemePref>(
                            segments: const [
                              ButtonSegment(
                                value: ThemePref.auto,
                                label: Text('Auto'),
                                icon: Icon(Icons.brightness_auto),
                              ),
                              ButtonSegment(
                                value: ThemePref.light,
                                label: Text('Claro'),
                                icon: Icon(Icons.light_mode),
                              ),
                              ButtonSegment(
                                value: ThemePref.dark,
                                label: Text('Oscuro'),
                                icon: Icon(Icons.dark_mode),
                              ),
                            ],
                            selected: {themeCtrl.pref},
                            onSelectionChanged: (selection) {
                              final pref = selection.first;
                              themeCtrl.setPref(pref);
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            themeCtrl.pref == ThemePref.auto
                                ? 'Automático según hora local (19:00–06:00 por defecto).'
                                : themeCtrl.pref == ThemePref.light
                                ? 'Tema claro activo.'
                                : 'Tema oscuro activo.',
                            style: text.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones
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

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'v.3686.1000',
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 92)),
        ],
      ),
    );
  }
}

// lib/settings/account_view.dart
import 'package:flutter/material.dart';
import 'profile_settings_view.dart';
import 'currency_view.dart';
import 'legal_view.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    const double p24 = 24;
    const double p16 = 16;

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
            side: const BorderSide(
              color: Color(0xFFE5E7EB),
            ), // mismo borde sutil que en las cards
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
                  // Logo con el mismo estilo que HomeView
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
                  const SizedBox(height: 28),

                  // inside AccountView -> pill list
                  pillButton(
                    Icons.settings,
                    'Settings',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileSettingsView()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  pillButton(Icons.mail_outline, 'Inbox'),
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

                  // Versión (alineada a la izquierda)
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

          // Espacio para que no choque con la bottom bar “glass”
          const SliverToBoxAdapter(child: SizedBox(height: 92)),
        ],
      ),
    );
  }
}
// fin de lib/settings/account_view.dart
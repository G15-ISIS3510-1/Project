// lib/settings/profile_settings_view.dart
import 'package:flutter/material.dart';
import '../Profile/visited_places.dart';

class ProfileSettingsView extends StatelessWidget {
  const ProfileSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    const double p24 = 24;
    const double p16 = 16;

    // Reusable pill button (same look as AccountView)
    Widget pillButton(IconData icon, String label, {VoidCallback? onTap}) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap ?? () {},
          icon: Icon(icon, size: 18, color: Colors.black87),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            elevation: 0,
          ),
        ),
      );
    }

    // Styles for bottom actions
    final ButtonStyle outlineNeutral = OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: const BorderSide(color: Color(0xFFE5E7EB)),
      padding: const EdgeInsets.symmetric(vertical: 12),
      textStyle: const TextStyle(fontSize: 14),
      foregroundColor: Colors.black87,
    );

    final ButtonStyle outlineDestructive = OutlinedButton.styleFrom(
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
                padding: const EdgeInsets.fromLTRB(p24, p24, p24, p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // X button on its own row
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 12),

                    // Settings title (left aligned)
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

                    // Profile block
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Juan Pablo Baron',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 6),
                              Text('3152403373', style: TextStyle(color: Colors.black54)),
                              SizedBox(height: 4),
                              Text('juanpa.baron18@gmail.com', style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFF2B2B2B), width: 3),
                          ),
                          child: const Icon(Icons.image, size: 28, color: Colors.black87),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Pills
                    pillButton(Icons.directions_car_filled_rounded, 'Add Car'),
                    const SizedBox(height: 16),
                    pillButton(
                      Icons.place_outlined,
                      'Visited Places',
                      onTap: () {
                        // Navigate to the VisitedPlacesScreen when tapped
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const VisitedPlacesScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    pillButton(Icons.notifications_none_rounded, 'Communications'),
                    const SizedBox(height: 16),
                    pillButton(Icons.credit_card_rounded, 'Payment'),

                    const SizedBox(height: 16),
                    const Divider(thickness: 2, color: Colors.black87),
                    const SizedBox(height: 16),

                    // Bottom actions (full width)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: outlineNeutral,
                        child: const Text('Switch Account'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: outlineDestructive,
                        child: const Text('Sign Out'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Spacer for glass bottom bar
            const SliverToBoxAdapter(child: SizedBox(height: 92)),
          ],
        ),
      ),
    );
  }
}
// fin de lib/settings/profile_settings_view.dart
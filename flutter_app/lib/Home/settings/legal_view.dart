import 'package:flutter/material.dart';

class LegalView extends StatelessWidget {
  const LegalView({super.key});

  @override
  Widget build(BuildContext context) {
    const double p24 = 24;
    const double p16 = 16;

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
                    // X close on its own row
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 12),

                    // Title (left aligned)
                    const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(thickness: 2, color: Colors.black87),
                    const SizedBox(height: 16),

                    // Terms box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Text(
                        '''
Qovo – Terms and Conditions

Last updated: 21/09/2025

Welcome to Qovo. These Terms and Conditions ("Terms") govern your use of the Qovo mobile application and its related services (collectively, the "Services"). By accessing or using the Qovo mobile app, you agree to be bound by these Terms. If you do not agree, you must not use the app.

1. Definitions
- "User" means any person who creates an account on the Qovo app.
- "Renter" means a User who books a vehicle through the Qovo app.
- "Owner" means a User who lists a vehicle for rent on the Qovo app.
- "Vehicle" means any car or automobile made available for rental through the Qovo app.
- "Agreement" refers to these Terms, along with our Privacy Policy.

2. Eligibility
- Users must be at least 21 years old (or the legal driving age in their jurisdiction).
- Renters must hold a valid driver’s license and meet Qovo’s verification requirements.
- By using the Qovo app, you confirm that all provided information is accurate and complete.
                        ''',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom spacer for glass bottom bar
            const SliverToBoxAdapter(child: SizedBox(height: 92)),
          ],
        ),
      ),
    );
  }
}

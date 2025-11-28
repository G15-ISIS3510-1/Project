import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/referral_viewmodel.dart';

import '../../analytics/time_analytics/data/time_tracker.dart';
import '../../analytics/time_analytics/data/time_storage.dart';
import 'package:share_plus/share_plus.dart';

class ReferralView extends StatefulWidget {
  const ReferralView({super.key});

  @override
  State<ReferralView> createState() => _ReferralViewState();
}

class _ReferralViewState extends State<ReferralView> {
  @override
  void initState() {
    super.initState();
    TimeTracker.start("referral_view");
  }

  @override
  void dispose() {
    final rec = TimeTracker.stop();
    if (rec != null) TimeStorage.save(rec);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReferralViewModel>();

    const p24 = 24.0;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(p24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: scheme.onSurface),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          "Refer a Friend",
                          style: text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(thickness: 2, color: scheme.outlineVariant),
                        const SizedBox(height: 28),

                        if (vm.loading)
                          const Center(child: CircularProgressIndicator()),

                        if (!vm.loading && vm.error == null)
                          _referralCard(vm),
                        const SizedBox(height: 32),

                        if (!vm.loading) _shareButtons(vm),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          if (vm.usedCache)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.orange.shade100,
                child: const Text(
                  "Offline — Showing cached referral code",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _referralCard(ReferralViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF5145FF), Color(0xFF7B61FF)],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 6),
            color: Colors.black26,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Your Referral Code",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),

          Text(
            vm.referralCode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: vm.copyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.copy),
            label: const Text("Copy Code"),
          ),
        ],
      ),
    );
  }

  Widget _shareButtons(ReferralViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Share your code",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _shareIcon(Icons.share, "Share", () async {
              final msg = await vm.buildShareMessage();
              Share.share(msg);
            }),

            _shareIcon(Icons.chat, "WhatsApp", () async {
              final msg = await vm.buildShareMessage();
              Share.share(msg, subject: msg);
            }),

            _shareIcon(Icons.email, "Email", () async {
              final msg = await vm.buildShareMessage();
              Share.share(msg);
            }),
          ],
        ),
      ],
    );
  }

  Widget _shareIcon(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}

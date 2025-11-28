import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/help_viewmodel.dart';

import '../../analytics/time_analytics/data/time_tracker.dart';
import '../../analytics/time_analytics/data/time_storage.dart';

class HelpView extends StatefulWidget {
  const HelpView({super.key});

  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> {
  @override
  void initState() {
    super.initState();
    TimeTracker.start("help_view");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HelpViewModel>().load();
    });
  }

  @override
  void dispose() {
    final rec = TimeTracker.stop();
    if (rec != null) TimeStorage.save(rec);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HelpViewModel>();

    const p24 = 24.0;
    const p16 = 16.0;
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(p24, p24, p24, p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: scheme.onSurface),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Help & Support',
                          style: text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Divider(thickness: 2, color: scheme.outlineVariant),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: vm.loading
                              ? const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(vm.faq,
                                        style: text.bodyMedium?.copyWith(height: 1.5)),
                                    const SizedBox(height: 28),
                                    Text(
                                      "Contact",
                                      style: text.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(vm.contact,
                                        style: text.bodyMedium?.copyWith(height: 1.5)),
                                  ],
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

          if (vm.usedCache)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.orange.shade100,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  "Offline — Showing Cached/Local Data",
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
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/about_viewmodel.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AboutViewModel()..loadAboutData(),
      child: const _AboutViewContent(),
    );
  }
}

class _AboutViewContent extends StatelessWidget {
  const _AboutViewContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AboutViewModel>();

    const double p24 = 24;
    const double p16 = 16;
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
                    padding: const EdgeInsets.fromLTRB(p24, p24, p24, p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Close button
                        IconButton(
                          icon: Icon(Icons.close, color: scheme.onSurface),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          'About Qovo',
                          style: text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Divider(thickness: 2, color: scheme.outlineVariant),
                        const SizedBox(height: 16),

                        // ABOUT BOX — identical structure to LegalView
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: vm.loading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Text(
                                  vm.aboutText,
                                  style: text.bodyMedium?.copyWith(
                                    height: 1.5,
                                    color: scheme.onSurface,
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
          ),

          // CACHE BANNER (same logic as OwnerIncomeView)
          if (vm.usedCache)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.orange.shade100,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  "Using Cache Data Until Reconnection",
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

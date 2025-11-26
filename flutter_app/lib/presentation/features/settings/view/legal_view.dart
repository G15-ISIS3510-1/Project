import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/legal_viewmodel.dart';
import '../../analytics/time_analytics/data/time_tracker.dart';
import '../../analytics/time_analytics/data/time_storage.dart';

class LegalView extends StatelessWidget {
  const LegalView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LegalViewModel()..loadLegalData(),
      child: const _LegalViewContent(),
    );
  }
}

class _LegalViewContent extends StatefulWidget {
  const _LegalViewContent({super.key});

  @override
  State<_LegalViewContent> createState() => _LegalViewContentState();
}

class _LegalViewContentState extends State<_LegalViewContent> {
  @override
  void initState() {
    super.initState();
    TimeTracker.start("legal_view");
  }

  @override
  void dispose() {
    final record = TimeTracker.stop();
    if (record != null) TimeStorage.save(record);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LegalViewModel>();

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
                        IconButton(
                          icon: Icon(Icons.close, color: scheme.onSurface),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Terms & Conditions',
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
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Text(
                                  vm.legalText,
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

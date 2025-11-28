// flutter_app/lib/presentation/features/analytics/recent_price_updates/view/recent_price_updates_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodel/recent_price_updates_viewmodel.dart';

class RecentPriceUpdatesView extends StatelessWidget {
  const RecentPriceUpdatesView({super.key});

  static final NumberFormat _fmt = NumberFormat.currency(symbol: '\$');

  String _formatCurrency(double? value) => _fmt.format(value ?? 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Average Updated Daily Price'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Selector<RecentPriceUpdatesViewModel, _RecentPriceState>(
            selector: (_, vm) => _RecentPriceState.from(vm),
            builder: (_, state, __) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.error != null) {
                return _ErrorView(
                  message: state.error!,
                  onRetry: () =>
                      context.read<RecentPriceUpdatesViewModel>().load(forceRefresh: true),
                );
              }
              return _SummaryView(
                averageText: _formatCurrency(state.averagePrice),
                sampleSize: state.sampleSize,
                usedCache: state.usedCache,
                fetchedAt: state.fetchedAt,
                text: text,
                scheme: scheme,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RecentPriceState {
  final bool loading;
  final String? error;
  final double? averagePrice;
  final int sampleSize;
  final bool usedCache;
  final DateTime? fetchedAt;

  _RecentPriceState({
    required this.loading,
    required this.error,
    required this.averagePrice,
    required this.sampleSize,
    required this.usedCache,
    required this.fetchedAt,
  });

  factory _RecentPriceState.from(RecentPriceUpdatesViewModel vm) => _RecentPriceState(
        loading: vm.loading,
        error: vm.error,
        averagePrice: vm.averagePrice,
        sampleSize: vm.sampleSize,
        usedCache: vm.usedCache,
        fetchedAt: vm.fetchedAt,
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: scheme.error, size: 32),
        const SizedBox(height: 12),
        Text(
          'Could not load data',
          style: text.titleMedium?.copyWith(color: scheme.error),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

class _SummaryView extends StatelessWidget {
  final String averageText;
  final int sampleSize;
  final bool usedCache;
  final DateTime? fetchedAt;
  final TextTheme text;
  final ColorScheme scheme;

  const _SummaryView({
    required this.averageText,
    required this.sampleSize,
    required this.usedCache,
    required this.fetchedAt,
    required this.text,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average daily price (last 7 days)',
                  style: text.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      averageText,
                      style: text.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$sampleSize vehicles',
                        style: text.labelLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text(
                        usedCache ? 'Cached' : 'Live',
                        style: text.labelMedium?.copyWith(color: scheme.onSurface),
                      ),
                      backgroundColor: usedCache
                          ? scheme.surfaceVariant
                          : scheme.primaryContainer,
                    ),
                    if (fetchedAt != null)
                      Chip(
                        label: Text(
                          'Updated ${DateFormat.yMMMd().add_jm().format(fetchedAt!.toLocal())}',
                          style:
                              text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        backgroundColor: scheme.surface,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'This metric calculates the average of daily prices for vehicles whose pricing was updated in the last 7 days.',
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: () => context
              .read<RecentPriceUpdatesViewModel>()
              .load(forceRefresh: true),
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh now'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../viewmodel/fees_taxes_viewmodel.dart';

class FeesTaxesView extends StatelessWidget {
  const FeesTaxesView({super.key});

  static final NumberFormat _fmt = NumberFormat.currency(symbol: r'$');

  String _formatCurrency(double? value) => _fmt.format(value ?? 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees & Taxes Average'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Selector<FeesTaxesViewModel, _FeesState>(
            selector: (_, vm) => _FeesState.from(vm),
            builder: (_, state, __) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.error != null) {
                return _ErrorView(
                  message: state.error!,
                  onRetry: () => context
                      .read<FeesTaxesViewModel>()
                      .load(forceRefresh: true),
                );
              }
              return _SummaryView(
                averageText: _formatCurrency(state.average),
                sampleSize: state.sampleSize,
                usedCache: state.usedCache,
                source: state.source,
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

class _FeesState {
  final bool loading;
  final String? error;
  final double? average;
  final int sampleSize;
  final bool usedCache;
  final String source;
  final DateTime? fetchedAt;

  _FeesState({
    required this.loading,
    required this.error,
    required this.average,
    required this.sampleSize,
    required this.usedCache,
    required this.source,
    required this.fetchedAt,
  });

  factory _FeesState.from(FeesTaxesViewModel vm) => _FeesState(
        loading: vm.loading,
        error: vm.error,
        average: vm.average,
        sampleSize: vm.sampleSize,
        usedCache: vm.usedCache,
        source: vm.source,
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
  final String source;
  final DateTime? fetchedAt;
  final TextTheme text;
  final ColorScheme scheme;

  const _SummaryView({
    required this.averageText,
    required this.sampleSize,
    required this.usedCache,
    required this.source,
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
                  'Average fees + taxes per booking',
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
                        '$sampleSize bookings',
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
                        style:
                            text.labelMedium?.copyWith(color: scheme.onSurface),
                      ),
                      backgroundColor: usedCache
                          ? scheme.surfaceVariant
                          : scheme.primaryContainer,
                    ),
                    Chip(
                      label: Text(
                        'Source: ${source.isEmpty ? 'unknown' : source}',
                        style:
                            text.labelMedium?.copyWith(color: scheme.onSurface),
                      ),
                      backgroundColor: scheme.surfaceVariant,
                    ),
                    if (fetchedAt != null)
                      Chip(
                        label: Text(
                          'Updated ${DateFormat.yMMMd().add_jm().format(fetchedAt!.toLocal())}',
                          style: text.labelMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
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
          'This metric sums fees and taxes for each booking and averages them across your bookings.',
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: () =>
              context.read<FeesTaxesViewModel>().load(forceRefresh: true),
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh now'),
        ),
      ],
    );
  }
}

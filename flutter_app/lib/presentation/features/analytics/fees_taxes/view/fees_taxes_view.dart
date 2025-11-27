import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../viewmodel/fees_taxes_viewmodel.dart';

class FeesTaxesView extends StatelessWidget {
  const FeesTaxesView({super.key});

  String _formatCurrency(double? value) {
    final v = value ?? 0;
    return NumberFormat.currency(symbol: r'$').format(v);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FeesTaxesViewModel>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    Widget body;
    if (vm.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.error != null) {
      body = Column(
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
              vm.error!,
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => vm.load(forceRefresh: true),
            child: const Text('Retry'),
          ),
        ],
      );
    } else {
      body = Column(
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
                        _formatCurrency(vm.average),
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
                          '${vm.sampleSize} bookings',
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
                          vm.usedCache ? 'Cached' : 'Live',
                          style:
                              text.labelMedium?.copyWith(color: scheme.onSurface),
                        ),
                        backgroundColor: vm.usedCache
                            ? scheme.surfaceVariant
                            : scheme.primaryContainer,
                      ),
                      Chip(
                        label: Text(
                          'Source: ${vm.source.isEmpty ? 'unknown' : vm.source}',
                          style:
                              text.labelMedium?.copyWith(color: scheme.onSurface),
                        ),
                        backgroundColor: scheme.surfaceVariant,
                      ),
                      if (vm.fetchedAt != null)
                        Chip(
                          label: Text(
                            'Updated ${DateFormat.yMMMd().add_jm().format(vm.fetchedAt!.toLocal())}',
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
            onPressed: () => vm.load(forceRefresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh now'),
          ),
        ],
      );
    }

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
          child: body,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../analytics/time_analytics/data/time_tracker.dart';
import '../../analytics/time_analytics/data/time_storage.dart';

class CurrencyView extends StatefulWidget {
  const CurrencyView({super.key});

  @override
  State<CurrencyView> createState() => _CurrencyViewState();
}

class _CurrencyViewState extends State<CurrencyView> {
  final _currencies = const [
    _Currency(flag: '🇺🇸', name: 'United States Dollar', code: 'USD', symbol: r'$'),
    _Currency(flag: '🇪🇺', name: 'Euro', code: 'EUR', symbol: '€'),
    _Currency(flag: '🇬🇧', name: 'British Pound', code: 'GBP', symbol: '£'),
    _Currency(flag: '🇨🇴', name: 'Colombian Peso', code: 'COP', symbol: r'$'),
  ];

  int selected = 0;

  @override
  void initState() {
    super.initState();
    TimeTracker.start("currency_view");
  }

  @override
  void dispose() {
    final record = TimeTracker.stop();
    if (record != null) TimeStorage.save(record);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double p24 = 24;
    const double p16 = 16;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    Widget symbolPill(String symbol) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Text(
            symbol,
            style: text.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        );

    Widget currencyButton(int i, _Currency c) {
      final bool isSelected = i == selected;
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => setState(() => selected = i),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? scheme.surface : scheme.surfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: scheme.outlineVariant),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: Row(
            children: [
              Text(c.flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${c.name} · ${c.code}',
                  style: text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              symbolPill(c.symbol),
            ],
          ),
        ),
      );
    }

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
                    IconButton(
                      icon: Icon(Icons.close, color: scheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Preferred Currency',
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(thickness: 2, color: scheme.outlineVariant),
                    const SizedBox(height: 16),
                    for (int i = 0; i < _currencies.length; i++) ...[
                      currencyButton(i, _currencies[i]),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 92)),
          ],
        ),
      ),
    );
  }
}

class _Currency {
  final String flag;
  final String name;
  final String code;
  final String symbol;
  const _Currency({
    required this.flag,
    required this.name,
    required this.code,
    required this.symbol,
  });
}

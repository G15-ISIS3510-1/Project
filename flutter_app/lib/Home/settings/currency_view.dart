import 'package:flutter/material.dart';

class CurrencyView extends StatefulWidget {
  const CurrencyView({super.key});

  @override
  State<CurrencyView> createState() => _CurrencyViewState();
}

class _CurrencyViewState extends State<CurrencyView> {
  final _currencies = const [
    _Currency(flag: '🇺🇸', name: 'United States Dollar', code: 'USD', symbol: r'$'),
    _Currency(flag: '🇪🇺', name: 'Euro',                 code: 'EUR', symbol: '€'),
    _Currency(flag: '🇬🇧', name: 'British Pound',        code: 'GBP', symbol: '£'),
    _Currency(flag: '🇨🇴', name: 'Colombian Peso',       code: 'COP', symbol: r'$'),
  ];

  int selected = 0; // USD preselected

  @override
  Widget build(BuildContext context) {
    const double p24 = 24;
    const double p16 = 16;

    Widget symbolPill(String symbol) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(symbol, style: const TextStyle(fontWeight: FontWeight.w600)),
        );

    Widget currencyButton(int i, _Currency c) {
      final bool isSelected = i == selected;
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => setState(() => selected = i),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? Colors.white : const Color(0xFFF2F2F7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: Row(
            children: [
              Text(c.flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${c.name} · ${c.code}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
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
                      'Preferred Currency',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(thickness: 2, color: Colors.black87),
                    const SizedBox(height: 16),

                    // Currency options
                    for (int i = 0; i < _currencies.length; i++) ...[
                      currencyButton(i, _currencies[i]),
                      const SizedBox(height: 20),
                    ],
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

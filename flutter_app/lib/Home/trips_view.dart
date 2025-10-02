import 'package:flutter/material.dart';
import '../home/widgets/bottom_bar.dart'; // tu bottom bar actual
import 'package:flutter_app/Home/widgets/search_bar.dart' as qovo;
import 'package:flutter_app/home/widgets/tab_navigation.dart';

import 'package:flutter_app/Home/widgets/trip_filter.dart';
import 'package:flutter_app/Home/widgets/trip_card.dart';

class TripsView extends StatefulWidget {
  const TripsView({super.key});

  @override
  State<TripsView> createState() => _TripsViewState();
}

class _TripsViewState extends State<TripsView> {
  int _current = 1; // Trip seleccionado en el bottom bar
  TripFilter _filter = TripFilter.all;

  static const double kBarHeight = 76;
  static const double kBarVPad = 12;

  final _items = const [
    TripItem(title: 'Mercedes Blue 2023', date: '17 May 2025'),
    TripItem(title: 'BMW X5 2022', date: '02 Jun 2025'),
    TripItem(title: 'Audi A4 2021', date: '11 Jun 2025'),
    TripItem(title: 'Mercedes Blue 2023', date: '24 Jun 2025'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // --- contenido ---
          Positioned.fill(
            child: SafeArea(
              top: true,
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Transform.scale(
                              scaleY: 0.82,
                              child: Text(
                                'QOVO',
                                style: text.displaySmall?.copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w400,
                                  // usa onBackground según tema
                                  color: scheme.onBackground.withOpacity(0.95),
                                  letterSpacing: -7.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),

                          qovo.SearchBar(),
                        ],
                      ),
                    ),
                  ),

                  // filtros (segmented)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                      child: TripFilterSegmented(
                        value: _filter,
                        onChanged: (f) => setState(() => _filter = f),
                      ),
                    ),
                  ),

                  // lista de trips
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => TripCard(item: _items[i]),
                    ),
                  ),

                  // espacio final para el bottom bar
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: kBarHeight + kBarVPad + bottomInset + 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

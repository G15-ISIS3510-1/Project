// lib/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/vehicles/vehicle_service.dart';
import 'package:flutter_app/features/vehicles/vehicle.dart';
import 'package:flutter_app/features/pricing/pricing.dart';
import 'package:flutter_app/features/pricing/pricing_service.dart';

import 'widgets/car_card.dart';
import 'widgets/category_chips.dart';
import 'widgets/search_bar.dart' as qovo;

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin<HomeView> {
  @override
  bool get wantKeepAlive => true;

  late Future<List<Vehicle>> _future;
  final Map<String, Future<Pricing?>> _pricingFutures = {};

  static const double _p24 = 24;

  @override
  void initState() {
    super.initState();
    _future = VehicleService.list();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // para que la última card no quede oculta por la bottom bar
    final listBottomPadding = 76 + 12 + bottomInset + 8;

    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER (fijo) ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(_p24, _p24, _p24, 16),
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
                        color: scheme.onBackground.withOpacity(0.95),
                        letterSpacing: -7.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const qovo.SearchBar(),
                const SizedBox(height: 16),
                const CategoryChips(
                  items: [
                    'Cars',
                    'SUVs',
                    'Minivans',
                    'Trucks',
                    'Vans',
                    'Luxury',
                  ],
                ),
              ],
            ),
          ),

          // ── LISTA (scroll solo aquí) ──────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Vehicle>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snap.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final vehicles = snap.data ?? [];
                if (vehicles.isEmpty) {
                  return const Center(child: Text('No hay vehículos'));
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    _p24,
                    0,
                    _p24,
                    listBottomPadding,
                  ),
                  itemCount: vehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) {
                    final v = vehicles[i];
                    final transLabel = (v.transmission == 'AT')
                        ? 'Automatic'
                        : (v.transmission == 'MT' ? 'Manual' : v.transmission);

                    final fut = _pricingFutures[v.vehicle_id] ??=
                        PricingService.getByVehicle(v.vehicle_id);

                    return FutureBuilder<Pricing?>(
                      future: fut,
                      builder: (context, pSnap) {
                        final price =
                            (pSnap.data?.dailyPrice ?? v.pricePerDay ?? 80.0);

                        return CarCard(
                          title: v.title,
                          rating: v.rating ?? 4.7,
                          transmission: transLabel,
                          price: price,
                          onFavoriteToggle: () {},
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

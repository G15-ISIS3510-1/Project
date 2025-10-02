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

  // Cache de futures para no pedir el pricing del mismo vehículo varias veces
  final Map<String, Future<Pricing?>> _pricingFutures = {};

  @override
  void initState() {
    super.initState();
    _future = VehicleService.list();
  }

  static const double _p24 = 24;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: true,
      bottom: false,
      child: CustomScrollView(
        slivers: [
          // Header + filtros
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(_p24, _p24, _p24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Transform.scale(
                      scaleY: 0.82,
                      child: const Text(
                        'QOVO',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          letterSpacing: -7.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  qovo.SearchBar(),
                  SizedBox(height: 16),
                  CategoryChips(
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
          ),

          // Lista de vehículos (con pricing real por ítem)
          SliverFillRemaining(
            hasScrollBody: true,
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
                  padding: const EdgeInsets.symmetric(horizontal: _p24),
                  itemCount: vehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) {
                    final v = vehicles[i];

                    // traducimos "AT"/"MT" si te llega así; si no, usa v.transmission directo
                    final transLabel = (v.transmission == 'AT')
                        ? 'Automatic'
                        : (v.transmission == 'MT' ? 'Manual' : v.transmission);

                    // pido/cacho el pricing para este vehículo
                    final fut = _pricingFutures[v.vehicle_id] ??=
                        PricingService.getByVehicle(v.vehicle_id);

                    return FutureBuilder<Pricing?>(
                      future: fut,
                      builder: (context, pSnap) {
                        // si hay error de pricing, solo mostramos fallback
                        final price =
                            (pSnap.data?.dailyPrice ?? v.pricePerDay ?? 80.0);

                        return CarCard(
                          title: v.title,
                          rating:
                              v.rating ??
                              4.7, // fallback si tu API no manda rating
                          transmission: transLabel,
                          price: price, // 👈 SIEMPRE double no nulo
                          onFavoriteToggle: () {},
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // espacio para el bottom bar del shell
          SliverToBoxAdapter(
            child: SizedBox(height: 76 + 12 + bottomInset + 8),
          ),
        ],
      ),
    );
  }
}

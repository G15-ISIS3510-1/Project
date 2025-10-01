// lib/host/host_home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/features/vehicles/vehicle_service.dart';
import 'package:flutter_app/features/vehicles/vehicle.dart';
import 'package:flutter_app/features/pricing/pricing.dart';
import 'package:flutter_app/features/pricing/pricing_service.dart';

import '../home/widgets/car_card.dart';
import '../home/widgets/category_chips.dart';
import '../home/widgets/search_bar.dart' as qovo;
import '../host_mode_provider.dart';

// 👇 ajusta este import a donde vivirá tu pantalla para crear vehículo
import 'package:flutter_app/Home/add_vehicle_view.dart';

class HostHomeView extends StatefulWidget {
  final String currentUserId;
  const HostHomeView({super.key, required this.currentUserId});

  @override
  State<HostHomeView> createState() => _HostHomeViewState();
}

class _HostHomeViewState extends State<HostHomeView>
    with AutomaticKeepAliveClientMixin<HostHomeView> {
  @override
  bool get wantKeepAlive => true;

  late Future<List<Vehicle>> _future;
  final Map<String, Future<Pricing?>> _pricingFutures = {};
  static const double _p24 = 24;

  @override
  void initState() {
    super.initState();
    // Si tu API ya tiene endpoint by owner, úsalo (listByOwner)
    // Si no, traemos todo y filtramos por ownerId == currentUserId
    _future = _loadMyVehicles();
  }

  Future<List<Vehicle>> _loadMyVehicles() async {
    try {
      // Opción A (si existe): return VehicleService.listByOwner(widget.currentUserId);
      final all = await VehicleService.list();
      return all.where((v) => v.ownerId == widget.currentUserId).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isHost = context.watch<HostModeProvider>().isHostMode;

    return SafeArea(
      top: true,
      bottom: false,
      child: CustomScrollView(
        slivers: [
          // Header + filtros (puedes ajustar categorías si quieres)
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
                  const SizedBox(height: 20),
                  qovo.SearchBar(),
                  const SizedBox(height: 16),
                  const CategoryChips(
                    items: [
                      'My cars',
                      'SUVs',
                      'Minivans',
                      'Trucks',
                      'Vans',
                      'Luxury',
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isHost)
                    Text(
                      'You are in Host mode',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // CTA: tarjeta “Agregar carro”
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(_p24, 0, _p24, 16),
              child: _AddCarCard(
                onTap: () async {
                  final created = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const AddVehicleView()),
                  );
                  // si se creó, refrescamos la lista
                  if (created == true && mounted) {
                    setState(() => _future = _loadMyVehicles());
                  }
                },
              ),
            ),
          ),

          // Lista de mis vehículos
          SliverFillRemaining(
            hasScrollBody: true,
            child: FutureBuilder<List<Vehicle>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final vehicles = snap.data ?? [];
                if (vehicles.isEmpty) {
                  return const _EmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: _p24),
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
                          // Puedes agregar onTap para editar vehículo
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: 76 + 12 + bottomInset + 8),
          ),
        ],
      ),

      // FAB adicional para agregar vehículo
      // (dos formas de llegar: card y este FAB)
    );
  }
}

class _AddCarCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCarCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.add_circle_outline, size: 28, color: Colors.black87),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Add a new car to your listings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_car_filled_rounded,
            size: 64,
            color: Colors.black26,
          ),
          const SizedBox(height: 12),
          const Text(
            'No cars listed yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the card above to add your first car.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

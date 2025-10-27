// lib/presentation/features/home/view/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/features/booking/view/create_booking_view.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/presentation/common_widgets/car_card.dart';
import 'package:flutter_app/presentation/common_widgets/category_chips.dart';
import 'package:flutter_app/presentation/common_widgets/search_bar.dart'
    as qovo;

import 'package:flutter_app/data/models/pricing_model.dart';
import 'package:flutter_app/presentation/features/home/viewmodel/home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin<HomeView> {
  @override
  bool get wantKeepAlive => true;

  static const double _p24 = 24;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final listBottomPadding = 76 + 12 + bottomInset + 8;

    return SafeArea(
      top: true,
      bottom: false,
      child: Consumer<HomeViewModel>(
        builder: (_, vm, __) {
          Widget body;
          switch (vm.status) {
            case HomeStatus.loading:
              body = const Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
              break;
            case HomeStatus.error:
              body = Expanded(
                child: Center(
                  child: Text(vm.error ?? 'Error', textAlign: TextAlign.center),
                ),
              );
              break;
            case HomeStatus.ready:
              final vehicles = vm.vehicles;
              if (vehicles.isEmpty) {
                body = const Expanded(
                  child: Center(child: Text('No hay vehículos')),
                );
              } else {
                body = Expanded(
                  child: RefreshIndicator(
                    onRefresh: vm.refresh,
                    child: ListView.separated(
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
                            : (v.transmission == 'MT'
                                  ? 'Manual'
                                  : (v.transmission));

                        return FutureBuilder<Pricing?>(
                          future: vm.priceFutureFor(v.vehicle_id),
                          builder: (context, pSnap) {
                            final price =
                                (pSnap.data?.dailyPrice ??
                                v.pricePerDay ??
                                80.0);
                            return CarCard(
                              title: v.title,
                              rating: v.rating ?? 4.7,
                              transmission: transLabel ?? '—',
                              price: price,
                              onFavoriteToggle: () {},
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CreateBookingScreen(
                                      initialVehicleId: v.vehicle_id,
                                      initialHostId: v.ownerId,
                                      initialDailyPrice: price,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              }
              break;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER
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
                    qovo.SearchBar(
                      onChanged: vm.setQuery, // 🔗 búsqueda al VM
                    ),
                    const SizedBox(height: 16),
                    CategoryChips(
                      items: const [
                        'Cars',
                        'SUVs',
                        'Minivans',
                        'Trucks',
                        'Vans',
                        'Luxury',
                      ],
                      onSelected: vm.setCategory, // 🔗 categoría al VM
                    ),
                  ],
                ),
              ),
              // ── LISTA / ESTADOS
              body,
            ],
          );
        },
      ),
    );
  }
}

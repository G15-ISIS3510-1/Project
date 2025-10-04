// // // lib/presentation/features/host_home/view/host_home_view.dart
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';

// // import 'package:flutter_app/data/sources/remote/vehicle_remote_source.dart';
// // import 'package:flutter_app/data/models/vehicle_model.dart';
// // import 'package:flutter_app/data/models/pricing_model.dart';
// // import 'package:flutter_app/data/sources/remote/pricing_remote_source.dart';

// // import 'package:flutter_app/presentation/common_widgets/car_card.dart';
// // import 'package:flutter_app/presentation/common_widgets/category_chips.dart';
// // import 'package:flutter_app/presentation/common_widgets/search_bar.dart'
// //     as qovo;

// // import 'package:flutter_app/presentation/features/app_shell/viewmodel/host_mode_provider.dart';
// // import 'package:flutter_app/presentation/features/vehicle/view/add_vehicle_view.dart';

// // class HostHomeView extends StatefulWidget {
// //   final String currentUserId;
// //   const HostHomeView({super.key, required this.currentUserId});

// //   @override
// //   State<HostHomeView> createState() => _HostHomeViewState();
// // }

// // class _HostHomeViewState extends State<HostHomeView>
// //     with AutomaticKeepAliveClientMixin<HostHomeView> {
// //   @override
// //   bool get wantKeepAlive => true;

// //   late Future<List<Vehicle>> _future;
// //   final Map<String, Future<Pricing?>> _pricingFutures = {};
// //   static const double _p24 = 24;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _future = _loadMyVehicles();
// //   }

// //   Future<List<Vehicle>> _loadMyVehicles() async {
// //     final all = await VehicleService.list();
// //     return all.where((v) => v.ownerId == widget.currentUserId).toList();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     super.build(context);
// //     final bottomInset = MediaQuery.of(context).padding.bottom;
// //     final isHost = context.watch<HostModeProvider>().isHostMode;
// //     final scheme = Theme.of(context).colorScheme;
// //     final text = Theme.of(context).textTheme;

// //     // Altura extra para que la última card no quede detrás de la bottom bar
// //     final listBottomPadding = 76 + 12 + bottomInset + 8;

// //     return SafeArea(
// //       top: true,
// //       bottom: false,
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // ── HEADER (fijo) ─────────────────────────────────────────────
// //           Padding(
// //             padding: const EdgeInsets.fromLTRB(_p24, _p24, _p24, 16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 qovo.SearchBar(),
// //                 const SizedBox(height: 16),
// //                 const CategoryChips(
// //                   items: [
// //                     'My cars',
// //                     'SUVs',
// //                     'Minivans',
// //                     'Trucks',
// //                     'Vans',
// //                     'Luxury',
// //                   ],
// //                 ),
// //                 const SizedBox(height: 8),
// //                 if (isHost)
// //                   Text(
// //                     'You are in Host mode',
// //                     style: text.bodyMedium?.copyWith(
// //                       color: scheme.onSurfaceVariant,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 const SizedBox(height: 12),
// //                 _AddCarCard(
// //                   onTap: () async {
// //                     final created = await Navigator.of(context).push<bool>(
// //                       MaterialPageRoute(builder: (_) => const AddVehicleView()),
// //                     );
// //                     if (created == true && mounted) {
// //                       setState(() => _future = _loadMyVehicles());
// //                     }
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),

// //           // ── LISTA (scroll solo aquí) ──────────────────────────────────
// //           Expanded(
// //             child: FutureBuilder<List<Vehicle>>(
// //               future: _future,
// //               builder: (context, snap) {
// //                 if (snap.connectionState == ConnectionState.waiting) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 }
// //                 if (snap.hasError) {
// //                   return Center(child: Text('Error: ${snap.error}'));
// //                 }
// //                 final vehicles = snap.data ?? [];
// //                 if (vehicles.isEmpty) {
// //                   return const _EmptyState();
// //                 }

// //                 return ListView.separated(
// //                   padding: EdgeInsets.fromLTRB(
// //                     _p24,
// //                     0,
// //                     _p24,
// //                     listBottomPadding,
// //                   ),
// //                   itemCount: vehicles.length,
// //                   separatorBuilder: (_, __) => const SizedBox(height: 16),
// //                   itemBuilder: (_, i) {
// //                     final v = vehicles[i];
// //                     final transLabel = (v.transmission == 'AT')
// //                         ? 'Automatic'
// //                         : (v.transmission == 'MT' ? 'Manual' : v.transmission);

// //                     final fut = _pricingFutures[v.vehicle_id] ??=
// //                         PricingService.getByVehicle(v.vehicle_id);

// //                     return FutureBuilder<Pricing?>(
// //                       future: fut,
// //                       builder: (context, pSnap) {
// //                         final price =
// //                             (pSnap.data?.dailyPrice ?? v.pricePerDay ?? 80.0);
// //                         return CarCard(
// //                           title: v.title,
// //                           rating: v.rating ?? 4.7,
// //                           transmission: transLabel,
// //                           price: price,
// //                           onFavoriteToggle: () {},
// //                         );
// //                       },
// //                     );
// //                   },
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class _AddCarCard extends StatelessWidget {
// //   final VoidCallback onTap;
// //   const _AddCarCard({required this.onTap});

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final scheme = theme.colorScheme;
// //     final text = theme.textTheme;

// //     return InkWell(
// //       onTap: onTap,
// //       borderRadius: BorderRadius.circular(14),
// //       splashColor: scheme.primary.withOpacity(0.08),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: theme.cardColor,
// //           borderRadius: BorderRadius.circular(14),
// //           border: Border.all(color: scheme.outlineVariant),
// //         ),
// //         padding: const EdgeInsets.all(16),
// //         child: Row(
// //           children: [
// //             Icon(Icons.add_circle_outline, size: 28, color: scheme.primary),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: Text(
// //                 'Add a new car to your listings',
// //                 style: text.bodyLarge?.copyWith(
// //                   fontWeight: FontWeight.w600,
// //                   color: scheme.onSurface,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _EmptyState extends StatelessWidget {
// //   const _EmptyState();

// //   @override
// //   Widget build(BuildContext context) {
// //     final scheme = Theme.of(context).colorScheme;
// //     final text = Theme.of(context).textTheme;

// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 24),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             Icons.directions_car_filled_rounded,
// //             size: 64,
// //             color: scheme.onSurfaceVariant,
// //           ),
// //           const SizedBox(height: 12),
// //           Text(
// //             'No cars listed yet',
// //             style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             'Tap the card above to add your first car.',
// //             textAlign: TextAlign.center,
// //             style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // lib/presentation/features/host_home/view/host_home_view.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:flutter_app/presentation/common_widgets/car_card.dart';
// import 'package:flutter_app/presentation/common_widgets/category_chips.dart';
// import 'package:flutter_app/presentation/common_widgets/search_bar.dart'
//     as qovo;

// import 'package:flutter_app/presentation/features/app_shell/viewmodel/host_mode_provider.dart';
// import 'package:flutter_app/presentation/features/vehicle/view/add_vehicle_view.dart';
// import 'package:flutter_app/presentation/features/host_home/viewmodel/host_home_viewmodel.dart';
// import 'package:flutter_app/data/models/pricing_model.dart';

// class HostHomeView extends StatefulWidget {
//   final String currentUserId;
//   const HostHomeView({super.key, required this.currentUserId});

//   @override
//   State<HostHomeView> createState() => _HostHomeViewState();
// }

// class _HostHomeViewState extends State<HostHomeView>
//     with AutomaticKeepAliveClientMixin<HostHomeView> {
//   @override
//   bool get wantKeepAlive => true;

//   static const double _p24 = 24;

//   @override
//   void initState() {
//     super.initState();
//     // Inicializa el VM una sola vez
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       context.read<HostHomeViewModel>().init();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final bottomInset = MediaQuery.of(context).padding.bottom;
//     final isHost = context.watch<HostModeProvider>().isHostMode;
//     final scheme = Theme.of(context).colorScheme;
//     final text = Theme.of(context).textTheme;

//     // Altura extra para que la última card no quede detrás de la bottom bar
//     final listBottomPadding = 76 + 12 + bottomInset + 8;

//     return SafeArea(
//       top: true,
//       bottom: false,
//       child: Consumer<HostHomeViewModel>(
//         builder: (_, vm, __) {
//           Widget body;

//           switch (vm.status) {
//             case HostHomeStatus.loading:
//               body = const Expanded(
//                 child: Center(child: CircularProgressIndicator()),
//               );
//               break;

//             case HostHomeStatus.error:
//               body = Expanded(
//                 child: Center(
//                   child: Text(vm.error ?? 'Error', textAlign: TextAlign.center),
//                 ),
//               );
//               break;

//             case HostHomeStatus.ready:
//               final vehicles = vm.vehicles;
//               if (vehicles.isEmpty) {
//                 body = Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(bottom: listBottomPadding),
//                     child: const _EmptyState(),
//                   ),
//                 );
//               } else {
//                 body = Expanded(
//                   child: RefreshIndicator(
//                     onRefresh: vm.refresh,
//                     child: ListView.separated(
//                       padding: EdgeInsets.fromLTRB(
//                         _p24,
//                         0,
//                         _p24,
//                         listBottomPadding,
//                       ),
//                       itemCount: vehicles.length,
//                       separatorBuilder: (_, __) => const SizedBox(height: 16),
//                       itemBuilder: (_, i) {
//                         final v = vehicles[i];
//                         final transLabel = (v.transmission == 'AT')
//                             ? 'Automatic'
//                             : (v.transmission == 'MT'
//                                   ? 'Manual'
//                                   : (v.transmission));

//                         return FutureBuilder<Pricing?>(
//                           future: vm.priceFutureFor(v.vehicle_id),
//                           builder: (context, pSnap) {
//                             final price =
//                                 (pSnap.data?.dailyPrice ??
//                                 v.pricePerDay ??
//                                 80.0);
//                             return CarCard(
//                               title: v.title,
//                               rating: v.rating ?? 4.7,
//                               transmission: transLabel ?? '—',
//                               price: price,
//                               onFavoriteToggle: () {},
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               }
//               break;
//           }

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── HEADER (fijo) ─────────────────────────────────────────────
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(_p24, _p24, _p24, 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     qovo.SearchBar(
//                       onChanged: vm.setQuery, // 🔗 búsqueda → VM
//                     ),
//                     const SizedBox(height: 16),
//                     CategoryChips(
//                       items: const [
//                         'My cars',
//                         'SUVs',
//                         'Minivans',
//                         'Trucks',
//                         'Vans',
//                         'Luxury',
//                       ],
//                       onSelected: vm.setCategory, // 🔗 categoría → VM
//                     ),
//                     const SizedBox(height: 8),
//                     if (isHost)
//                       Text(
//                         'You are in Host mode',
//                         style: text.bodyMedium?.copyWith(
//                           color: scheme.onSurfaceVariant,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     const SizedBox(height: 12),
//                     _AddCarCard(
//                       onTap: () async {
//                         final created = await Navigator.of(context).push<bool>(
//                           MaterialPageRoute(
//                             builder: (_) => const AddVehicleView(),
//                           ),
//                         );
//                         if (created == true && context.mounted) {
//                           await context
//                               .read<HostHomeViewModel>()
//                               .onVehicleCreated();
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               // ── LISTA / ESTADOS ──────────────────────────────────────────
//               body,
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class _AddCarCard extends StatelessWidget {
//   final VoidCallback onTap;
//   const _AddCarCard({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final text = Theme.of(context).textTheme;

//     return Center(
//       // 👈 centra el contenido en el espacio disponible
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // 👈 alto justo del contenido
//           children: [
//             Icon(
//               Icons.directions_car_filled_rounded,
//               size: 64,
//               color: scheme.onSurfaceVariant,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'No cars listed yet',
//               style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Tap the card above to add your first car.',
//               textAlign: TextAlign.center,
//               style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   const _EmptyState();

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final text = Theme.of(context).textTheme;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.directions_car_filled_rounded,
//             size: 64,
//             color: scheme.onSurfaceVariant,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'No cars listed yet',
//             style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Tap the card above to add your first car.',
//             textAlign: TextAlign.center,
//             style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/presentation/common_widgets/car_card.dart';
import 'package:flutter_app/presentation/common_widgets/category_chips.dart';
import 'package:flutter_app/presentation/common_widgets/search_bar.dart'
    as qovo;

import 'package:flutter_app/presentation/features/app_shell/viewmodel/host_mode_provider.dart';
import 'package:flutter_app/presentation/features/vehicle/view/add_vehicle_view.dart';
import 'package:flutter_app/presentation/features/host_home/viewmodel/host_home_viewmodel.dart';
import 'package:flutter_app/data/models/pricing_model.dart';

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

  static const double _p24 = 24;

  @override
  void initState() {
    super.initState();
    // Inicializa el VM una sola vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HostHomeViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isHost = context.watch<HostModeProvider>().isHostMode;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Altura extra para que la última card no quede detrás de la bottom bar
    final listBottomPadding = 76 + 12 + bottomInset + 8;

    return SafeArea(
      top: true,
      bottom: false,
      child: Consumer<HostHomeViewModel>(
        builder: (_, vm, __) {
          Widget body;

          switch (vm.status) {
            case HostHomeStatus.loading:
              body = const Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
              break;

            case HostHomeStatus.error:
              body = Expanded(
                child: Center(
                  child: Text(vm.error ?? 'Error', textAlign: TextAlign.center),
                ),
              );
              break;

            case HostHomeStatus.ready:
              final vehicles = vm.vehicles;
              if (vehicles.isEmpty) {
                body = Expanded(
                  child: Padding(
                    // mismo fondo libre que la ListView, para que se vea realmente centrado
                    padding: EdgeInsets.only(bottom: listBottomPadding),
                    child: const _EmptyState(),
                  ),
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
                                  : v.transmission);

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
                              transmission: transLabel,
                              price: price,
                              onFavoriteToggle: () {},
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
              // ── HEADER (fijo) ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(_p24, _p24, _p24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    qovo.SearchBar(
                      onChanged: vm.setQuery, // búsqueda → VM
                    ),
                    const SizedBox(height: 16),
                    CategoryChips(
                      items: const [
                        'My cars',
                        'SUVs',
                        'Minivans',
                        'Trucks',
                        'Vans',
                        'Luxury',
                      ],
                      onSelected: vm.setCategory, // categoría → VM
                    ),
                    const SizedBox(height: 8),
                    if (isHost)
                      Text(
                        'You are in Host mode',
                        style: text.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 12),
                    _AddCarCard(
                      onTap: () async {
                        final created = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const AddVehicleView(),
                          ),
                        );
                        if (created == true && context.mounted) {
                          await context
                              .read<HostHomeViewModel>()
                              .onVehicleCreated();
                        }
                      },
                    ),
                  ],
                ),
              ),

              // ── LISTA / ESTADOS ──────────────────────────────────────────
              body,
            ],
          );
        },
      ),
    );
  }
}

class _AddCarCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCarCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: scheme.primary.withOpacity(0.08),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, size: 28, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Add a new car to your listings',
                style: text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
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
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      // centra el bloque en el espacio disponible
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min, // alto justo del contenido
          children: [
            Icon(
              Icons.directions_car_filled_rounded,
              size: 64,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No cars listed yet',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the card above to add your first car.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

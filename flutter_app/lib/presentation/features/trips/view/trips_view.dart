// lib/presentation/features/trips/view/trips_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/presentation/common_widgets/search_bar.dart'
    as qovo;
import 'package:flutter_app/presentation/common_widgets/trip_filter.dart';
import 'package:flutter_app/presentation/common_widgets/trip_card.dart';
import 'package:flutter_app/presentation/features/trips/viewmodel/trips_viewmodel.dart';

class TripsView extends StatefulWidget {
  const TripsView({super.key});

  @override
  State<TripsView> createState() => _TripsViewState();
}

class _TripsViewState extends State<TripsView> {
  static const double kBarHeight = 76;
  static const double kBarVPad = 12;

  // ¡Inicialízalo aquí para evitar LateInitializationError!
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final vm = context.read<TripsViewModel>(); // viene de main.dart
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        vm.loadMore();
      }
    });

    // No llames vm.init() aquí; ya lo hiciste en main.dart con ..init()
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final vm = context.watch<TripsViewModel>(); // ✅ usa el provider global
    final status = vm.status;

    Widget sliverBody;
    if (status == TripsStatus.loading && !vm.isRefreshing) {
      sliverBody = const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (status == TripsStatus.error) {
      sliverBody = SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Icon(
                Icons.error_outline,
                size: 56,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                vm.error ?? 'Error',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: vm.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    } else {
      final items = vm.items;
      if (items.isEmpty) {
        sliverBody = SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 56,
                  color: Colors.grey.withOpacity(0.7),
                ),
                const SizedBox(height: 8),
                const Text('No hay viajes aún'),
                const SizedBox(height: 8),
                Text(
                  '¡Reserva un vehículo para verlo aquí!',
                  style: TextStyle(color: Colors.grey.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        );
      } else {
        sliverBody = SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList.separated(
            itemCount: items.length + (vm.hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              if (i >= items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return TripCard(item: items[i]);
            },
          ),
        );
      }
    }

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: vm.refresh,
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              // Header
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
                              color: scheme.onBackground.withOpacity(0.95),
                              letterSpacing: -7.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      qovo.SearchBar(onChanged: vm.setQuery),
                    ],
                  ),
                ),
              ),
              // Filtros
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: TripFilterSegmented(
                    value: vm.filter,
                    onChanged: vm.setFilter,
                  ),
                ),
              ),
              // Lista / estados
              sliverBody,
              // espacio final por si tienes bottom bar
              SliverToBoxAdapter(
                child: SizedBox(
                  height: kBarHeight + kBarVPad + bottomInset + 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

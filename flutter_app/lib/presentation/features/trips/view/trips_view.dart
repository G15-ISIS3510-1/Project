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

  final ScrollController _scroll = ScrollController();

  @override
<<<<<<< HEAD
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final vm = context.read<TripsViewModel>(); // viene de main.dart
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        vm.loadMore();
      }

      if (_scroll.position.pixels <= _scroll.position.minScrollExtent + 50 &&
          !_scroll.position.outOfRange &&
          !vm.isRefreshing) {
        vm.refresh();
      }
    });

    // No llames vm.init() aquí; ya lo hiciste en main.dart con ..init()
  }

  @override
=======
>>>>>>> 7d9e48d (mark xii)
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final vm = context.watch<TripsViewModel>();
    final status = vm.status;

    // ---------- BODY (list / empty / error / loading) ----------
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
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              return TripCard(item: items[i]);
            },
          ),
        );
      }
    }

    // Show the pager pill whenever we’re not in the very first idle/loading
    final showPager = status == TripsStatus.ready ||
        status == TripsStatus.error ||
        vm.isRefreshing;

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
              // Header (logo + search)
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

              // Filtros (All / Booked / History)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: TripFilterSegmented(
                    value: vm.filter,
                    onChanged: vm.setFilter,
                  ),
                ),
              ),

              // Pager pill (centered) styled like Home vehicles
              if (showPager)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Center(
                      child: _PagerPill(
                        pageNumber: vm.pageNumber,
                        canPrev: vm.canPrevPage,
                        canNext: vm.canNextPage,
                        onPrev: vm.canPrevPage
                            ? () {
                                vm.prevPage();
                                // optional: jump back to top smoothly
                                _scroll.animateTo(
                                  0,
                                  duration:
                                      const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                );
                              }
                            : null,
                        onNext: vm.canNextPage
                            ? () async {
                                await vm.nextPage();
                                if (mounted) {
                                  _scroll.animateTo(
                                    0,
                                    duration: const Duration(
                                        milliseconds: 250),
                                    curve: Curves.easeOut,
                                  );
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),

              // The bookings for this page
              sliverBody,

              // Spacer so bottom nav bar doesn't cover last card
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

/// Small rounded pill with "<   N   >"
/// Matches the style you showed on the car list.
class _PagerPill extends StatelessWidget {
  final int pageNumber;
  final bool canPrev;
  final bool canNext;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PagerPill({
    required this.pageNumber,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Color _arrowColor(bool enabled) =>
        enabled ? scheme.onSurface : scheme.onSurface.withOpacity(0.35);

    Widget _arrow({
      required IconData icon,
      required bool enabled,
      required VoidCallback? onTap,
    }) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: _arrowColor(enabled),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _arrow(
            icon: Icons.chevron_left,
            enabled: canPrev,
            onTap: onPrev,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$pageNumber',
              style: text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          _arrow(
            icon: Icons.chevron_right,
            enabled: canNext,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

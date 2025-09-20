import 'package:flutter/material.dart';
import 'widgets/category_chips.dart';
import 'widgets/car_card.dart';
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

  final _cars = const [
    _CarItem('Mercedes Blue 2023', 4.8, 'Automatic', 176037.11),
    _CarItem('BMW X5 2022', 4.7, 'Automatic', 132499.00),
    _CarItem('Audi A4 2021', 4.6, 'Manual', 92499.99),
  ];

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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: _p24),
            sliver: SliverList.separated(
              itemCount: _cars.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) {
                final c = _cars[i];
                return CarCard(
                  title: c.title,
                  rating: c.rating,
                  transmission: c.trans,
                  price: c.price,
                  onFavoriteToggle: () {},
                );
              },
            ),
          ),
          // reserva para el bottom bar del shell
          SliverToBoxAdapter(
            child: SizedBox(height: 76 + 12 + bottomInset + 8),
          ),
        ],
      ),
    );
  }
}

class _CarItem {
  final String title;
  final double rating;
  final String trans;
  final double price;
  const _CarItem(this.title, this.rating, this.trans, this.price);
}

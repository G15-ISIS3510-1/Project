import 'package:flutter/material.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/category_chips.dart';
import 'widgets/car_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _current = 0;

  // ------- MOCK DATA -------
  final List<_CarItem> _mockCars = const [
    _CarItem(
      title: 'Mercedes Blue 2023',
      rating: 4.8,
      transmission: 'Automatic',
      price: 176037.11,
    ),
    _CarItem(
      title: 'BMW X5 2022',
      rating: 4.7,
      transmission: 'Automatic',
      price: 132499.00,
    ),
    _CarItem(
      title: 'Audi A4 2021',
      rating: 4.6,
      transmission: 'Manual',
      price: 92499.99,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const double p24 = 24;
    const double p16 = 16;

    return Scaffold(
      bottomNavigationBar: BottomBar(
        currentIndex: _current,
        items: const [
          BottomBarItem(Icons.home_rounded, 'Home'),
          BottomBarItem(Icons.navigation_rounded, 'Trip'),
          BottomBarItem(Icons.chat_bubble_rounded, 'Messages'),
          BottomBarItem(Icons.dashboard_customize_rounded, 'Host'),
          BottomBarItem(Icons.person_rounded, 'Account'),
        ],
        onTap: (i) => setState(() => _current = i), // ahora sí cambia el blob
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(p24, p24, p24, p16),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              prefixIcon: const Icon(Icons.search, size: 22),
                              suffixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.mic_none_rounded),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: p24),
              sliver: SliverList.separated(
                itemCount: _mockCars.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final c = _mockCars[index];
                  return CarCard(
                    title: c.title,
                    rating: c.rating,
                    transmission: c.transmission,
                    price: c.price,
                    isFavorite: c.isFavorite,
                    onFavoriteToggle: () {},
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 92)),
          ],
        ),
      ),
    );
  }
}

// ------- Modelito simple para los mocks -------
class _CarItem {
  final String title;
  final double rating;
  final String transmission;
  final double price;
  final bool isFavorite;
  const _CarItem({
    required this.title,
    required this.rating,
    required this.transmission,
    required this.price,
    this.isFavorite = false,
  });
}

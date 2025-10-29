import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../../../../data/repositories/analytics_repository.dart';
import '../viewmodel/analytics_viewmodel.dart';

class AnalyticsView extends StatefulWidget {
  final AnalyticsRepositoryImpl repository;
  const AnalyticsView({super.key, required this.repository});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  late final AnalyticsViewModel _viewModel;
  bool loading = true;
  Map<String, int> rentalsByZone = {};

  @override
  void initState() {
    super.initState();
    _viewModel = AnalyticsViewModel(repository: widget.repository);
    _loadAndProcessData();
  }

  Future<void> _loadAndProcessData() async {
    await _viewModel.loadDemandPeaks();
    if (_viewModel.data.isNotEmpty) {
      await _geocodeAndGroup(_viewModel.data);
    }
    setState(() => loading = false);
  }

  Future<void> _geocodeAndGroup(List<dynamic> data) async {
    final Map<String, int> temp = {};

    for (var entry in data.take(25)) {
      final lat = entry['lat'];
      final lng = entry['lng'];
      final rentals = int.tryParse(entry['total_rentals'].toString()) ?? 0;

      try {
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&zoom=6',
        );
        final res = await http.get(
          uri,
          headers: {'User-Agent': 'RentalDemandApp/1.0 (contact: demo@uniandes.edu.co)'},
        );

        if (res.statusCode == 200) {
          final json = jsonDecode(res.body);
          final address = json['address'] ?? {};
          final city = address['city'] ??
              address['town'] ??
              address['state'] ??
              address['region'] ??
              'Unknown';
          final country = address['country'] ?? '';
          final zone = country.isNotEmpty ? '$city, $country' : city;
          temp[zone] = (temp[zone] ?? 0) + rentals;
          debugPrint('Mapped $lat,$lng -> $zone ($rentals rentals)');
        } else {
          debugPrint('HTTP ${res.statusCode} while translating $lat,$lng');
        }
      } catch (e) {
        debugPrint('Error translating coordinates $lat,$lng: $e');
      }
    }

    rentalsByZone = temp;
    debugPrint('Grouped rentals: $rentalsByZone');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (rentalsByZone.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No data available')),
      );
    }

    final maxY = rentalsByZone.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Rental Demand by Geographical Zone')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY + 2,
                  minY: 0,
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 70,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= rentalsByZone.length) return const SizedBox();
                          final zone = rentalsByZone.keys.elementAt(index);
                          return Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              zone,
                              style: const TextStyle(fontSize: 10, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value % 2 != 0) return const SizedBox();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(color: Colors.black54, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: List.generate(rentalsByZone.length, (i) {
                    final rentals = rentalsByZone.values.elementAt(i).toDouble();
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: rentals,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.blueAccent,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

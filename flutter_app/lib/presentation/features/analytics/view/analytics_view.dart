import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/analytics_repository.dart';
import '../viewmodel/analytics_viewmodel.dart';
import '/data/database/tables/analytics_table.dart';

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
    try {
      await _viewModel.loadDemandPeaks();
      if (_viewModel.data.isNotEmpty) {
        rentalsByZone = await compute(_geocodeAndGroupInBackground, _viewModel.data);
      }
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  static Future<Map<String, int>> _geocodeAndGroupInBackground(List<dynamic> data) async {
    final Map<String, int> temp = {};

    final cleaned = data.where((entry) {
      double? lat;
      double? lng;
      int? rentals;

      if (entry is Map<String, dynamic>) {
        lat = (entry['lat'] ?? 0).toDouble();
        lng = (entry['lng'] ?? 0).toDouble();
        rentals = int.tryParse(entry['total_rentals'].toString()) ?? 0;
      } else if (entry is AnalyticsDemandEntity) {
        lat = entry.latZone;
        lng = entry.lonZone;
        rentals = entry.rentals;
      }

      return lat != 0.0 && lng != 0.0 && rentals != 0;
    }).toList();

    final futures = cleaned.take(25).map((entry) async {
      double lat;
      double lng;
      int rentals;

      if (entry is Map<String, dynamic>) {
        lat = (entry['lat'] ?? 0).toDouble();
        lng = (entry['lng'] ?? 0).toDouble();
        rentals = int.tryParse(entry['total_rentals'].toString()) ?? 0;
      } else if (entry is AnalyticsDemandEntity) {
        lat = entry.latZone;
        lng = entry.lonZone;
        rentals = entry.rentals;
      } else {
        return null;
      }

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
          return MapEntry(zone, rentals);
        }
      } catch (_) {}
      return null;
    });

    final results = await Future.wait(futures);

    for (var result in results) {
      if (result != null) {
        temp[result.key] = (temp[result.key] ?? 0) + result.value;
      }
    }

    return temp;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rental Zones')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (rentalsByZone.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rental Zones'),
          leading: BackButton(onPressed: () => Navigator.pop(context)),
        ),
        body: const Center(child: Text('No data available')),
      );
    }

    final maxY = rentalsByZone.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Rental Demand by Geographical Zone'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          Padding(
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
                              if (index >= rentalsByZone.length) {
                                return const SizedBox();
                              }
                              final zone = rentalsByZone.keys.elementAt(index);
                              return Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  zone,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
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
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barGroups: List.generate(rentalsByZone.length, (i) {
                        final rentals =
                            rentalsByZone.values.elementAt(i).toDouble();
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

          if (_viewModel.usedCache)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.orange.shade100,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Using Cache Data Until Reconnection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

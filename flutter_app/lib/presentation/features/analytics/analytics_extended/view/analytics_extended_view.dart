import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../viewmodel/analytics_extended_viewmodel.dart';

class AnalyticsExtendedView extends StatefulWidget {
  const AnalyticsExtendedView({super.key});

  @override
  State<AnalyticsExtendedView> createState() => _AnalyticsExtendedViewState();
}

class _AnalyticsExtendedViewState extends State<AnalyticsExtendedView> {
  final Map<String, String> _zoneCache = {};
  Future<void>? _initialLoad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<AnalyticsExtendedViewModel>();
      _initialLoad = viewModel.fetchDemandPeaksExtended();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AnalyticsExtendedViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demand Peaks Extended'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.fetchDemandPeaksExtended(),
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initialLoad,
            builder: (context, snapshot) {
              if (viewModel.loading ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.demandPeaks.isEmpty) {
                return const Center(child: Text('No data available.'));
              }

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: compute(_addLocationsInBackground, {
                  "rawData": viewModel.demandPeaks,
                  "zoneCache": _zoneCache,
                }),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;
                  if (data.isEmpty) {
                    return const Center(child: Text('No data available.'));
                  }

                  return FutureBuilder<Map<String, dynamic>>(
                    future: compute(_computeSummaryInBackground, data),
                    builder: (context, summarySnap) {
                      if (!summarySnap.hasData || summarySnap.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final summary = summarySnap.data!;
                      return ListView(
                        children: [
                          ...data.map((item) => Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: ListTile(
                                  title: Text(
                                    '${item["make"] ?? "Unknown"} ${item["year"] ?? ""} • ${item["fuel_type"] ?? ""}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${item["location"]} | '
                                    'Hour: ${item["hour_slot"]} | '
                                    'Transmission: ${item["transmission"]}',
                                  ),
                                  trailing: Text(
                                    '${item["rentals"] ?? 0} rentals',
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Summary',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                    'Total brands: ${summary["brandsCount"] ?? 0}'),
                                Text(
                                    'Average year: ${(summary["averageYear"] ?? 0).toStringAsFixed(1)}'),
                                const SizedBox(height: 25),
                                const Text(
                                  'Transmission Distribution (%)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                _buildBarChart(summary["transmissionPercent"]),
                                const SizedBox(height: 30),
                                const Text(
                                  'Fuel Type Distribution (%)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                _buildBarChart(summary["fuelTypePercent"]),
                                const SizedBox(height: 30),
                                const Text(
                                  'Location Distribution (%)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                _buildBarChart(summary["locationPercent"]),
                                const SizedBox(height: 30),
                                const Text(
                                  'Brands Distribution (%)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                _buildBarChart(summary["brandsPercent"]),
                                const SizedBox(height: 30),
                                const Text(
                                  'Vehicle Year Distribution (%)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                _buildBarChart(summary["yearPercent"]),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          if (viewModel.usedCache)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.orange.shade100,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  '⚠️ Using Cache Data Until Reconnection',
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

  Widget _buildBarChart(Map<String, dynamic>? dataMapGroup) {
    if (dataMapGroup == null ||
        dataMapGroup["percent"] == null ||
        dataMapGroup["rentals"] == null) {
      return const Text('No data to display.');
    }

    final dataMap = dataMapGroup["percent"] as Map<String, double>;
    final rentalsMap = dataMapGroup["rentals"] as Map<String, int>;

    final sortedKeys = dataMap.keys.toList()
      ..sort((a, b) {
        final aNum = num.tryParse(a);
        final bNum = num.tryParse(b);
        if (aNum != null && bNum != null) return aNum.compareTo(bNum);
        return a.toString().compareTo(b.toString());
      });

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= sortedKeys.length) {
                    return const SizedBox.shrink();
                  }
                  return Transform.rotate(
                    angle: -0.4,
                    child: Text(
                      sortedKeys[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 4,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = sortedKeys[groupIndex];
                final percent = dataMap[label] ?? 0;
                final rentals = rentalsMap[label] ?? 0;
                return BarTooltipItem(
                  '$label\n${percent.toStringAsFixed(1)}% ($rentals)',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          barGroups: List.generate(sortedKeys.length, (i) {
            final key = sortedKeys[i];
            final percent = dataMap[key]!;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: percent,
                  width: 28,
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.blueAccent,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> _addLocationsInBackground(
    Map<String, dynamic> args) async {
  final rawData = args["rawData"] as List<dynamic>;
  final zoneCache = Map<String, String>.from(args["zoneCache"]);
  final List<Map<String, dynamic>> updated = [];

  for (var item in rawData) {
    final lat = item['lat_zone'];
    final lon = item['lon_zone'];
    final key = '$lat,$lon';
    String loc;
    if (zoneCache.containsKey(key)) {
      loc = zoneCache[key]!;
    } else {
      try {
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&zoom=6',
        );
        final response = await http.get(
          uri,
          headers: {'User-Agent': 'ExtendedDemandApp/1.0'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final address = data['address'] ?? {};
          final city = address['city'] ??
              address['town'] ??
              address['state'] ??
              address['region'] ??
              'Unknown';
          final country = address['country'] ?? '';
          loc = country.isNotEmpty ? '$city, $country' : city;
          zoneCache[key] = loc;
        } else {
          loc = 'Unknown';
        }
      } catch (_) {
        loc = 'Unknown';
      }
    }
    updated.add({...item, 'location': loc});
  }
  return updated;
}

Map<String, dynamic> _computeSummaryInBackground(
    List<Map<String, dynamic>> data) {
  final brands = <String, int>{};
  final years = <String, int>{};
  final transmissions = <String, int>{};
  final fuelTypes = <String, int>{};
  final locations = <String, int>{};
  double totalYears = 0;

  for (var item in data) {
    final rentals = (item['rentals'] ?? 0) as int;
    final make = item['make'] ?? 'Unknown';
    final fuel = item['fuel_type'] ?? 'Unknown';
    final loc = item['location'] ?? 'Unknown';
    final trans = item['transmission'] ?? 'Unknown';
    brands[make] = (brands[make] ?? 0) + rentals;
    transmissions[trans] = (transmissions[trans] ?? 0) + rentals;
    fuelTypes[fuel] = (fuelTypes[fuel] ?? 0) + rentals;
    locations[loc] = (locations[loc] ?? 0) + rentals;
    final year = (item['year'] ?? 0).toString();
    years[year] = (years[year] ?? 0) + rentals;
    totalYears += (item['year'] ?? 0).toDouble() * rentals;
  }

  final totalRentals =
      data.fold<int>(0, (prev, e) => prev + (e['rentals'] ?? 0) as int);

  Map<String, double> _toPercent(Map<String, int> map) {
    final result = <String, double>{};
    map.forEach((key, value) {
      result[key] = totalRentals == 0 ? 0 : (value / totalRentals * 100);
    });
    return result;
  }

  final sortedBrands = Map.fromEntries(
    brands.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );

  final sortedYears = Map.fromEntries(
    years.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );

  return {
    "brandsCount": brands.length,
    "averageYear":
        totalYears / (totalRentals == 0 ? 1 : totalRentals.toDouble()),
    "transmissionPercent": {
      "percent": _toPercent(transmissions),
      "rentals": transmissions
    },
    "fuelTypePercent": {
      "percent": _toPercent(fuelTypes),
      "rentals": fuelTypes
    },
    "locationPercent": {
      "percent": _toPercent(locations),
      "rentals": locations
    },
    "brandsPercent": {
      "percent": _toPercent(sortedBrands),
      "rentals": sortedBrands
    },
    "yearPercent": {
      "percent": _toPercent(sortedYears),
      "rentals": sortedYears
    },
  };
}

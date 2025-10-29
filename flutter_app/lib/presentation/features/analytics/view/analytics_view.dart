import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _viewModel = AnalyticsViewModel(repository: widget.repository);
    _viewModel.loadDemandPeaks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demand Peaks')),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          if (_viewModel.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.error != null) {
            return Center(child: Text('Error: ${_viewModel.error}'));
          }

          final data = _viewModel.data;
          if (data.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(show: true),
                gridData: FlGridData(show: false),
                barGroups: data.take(24).map((e) {
                  final hour = e['hour'] ?? 0;
                  final rentals = e['rentals'] ?? 0.0;
                  return BarChartGroupData(
                    x: hour.toInt(),
                    barRods: [
                      BarChartRodData(
                        toY: rentals.toDouble(),
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/analytics_extended_viewmodel.dart';

class AnalyticsExtendedView extends StatelessWidget {
  const AnalyticsExtendedView({super.key});

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
      body: viewModel.loading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.demandPeaks.isEmpty
              ? const Center(child: Text('No data available.'))
              : ListView.builder(
                  itemCount: viewModel.demandPeaks.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.demandPeaks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          '${item["make"] ?? "Unknown"} ${item["year"] ?? ""} • ${item["fuel_type"] ?? ""}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Zone: (${item["lat_zone"]}, ${item["lon_zone"]}) | '
                          'Hour: ${item["hour_slot"]} | Transmission: ${item["transmission"]}',
                        ),
                        trailing: Text(
                          '${item["rentals"] ?? 0} rentals',
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../viewmodel/owner_income_viewmodel.dart';

class OwnerIncomeView extends StatefulWidget {
  const OwnerIncomeView({super.key});

  @override
  State<OwnerIncomeView> createState() => _OwnerIncomeViewState();
}

class _OwnerIncomeViewState extends State<OwnerIncomeView> {
  Future<void>? _initialLoad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<OwnerIncomeViewModel>();
      _initialLoad = viewModel.fetchOwnerIncome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OwnerIncomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Income Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.fetchOwnerIncome(),
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

              if (viewModel.ownerIncome.isEmpty) {
                return const Center(child: Text('No income data available.'));
              }

              return FutureBuilder<Map<String, dynamic>>(
                future: compute(_computeAllInBackground, viewModel.ownerIncome),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final results = snapshot.data!;
                  final summary = results['summary'];
                  final grouped = results['grouped'];
                  final byOwner = results['byOwner'];

                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Summary',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _summaryBox(
                                  'Total Owners',
                                  summary['ownersCount'].toString(),
                                  Icons.people_alt,
                                  Colors.blueAccent,
                                ),
                                _summaryBox(
                                  'Total Income',
                                  '\$${summary['totalIncome'].toStringAsFixed(0)}',
                                  Icons.attach_money,
                                  Colors.green,
                                ),
                                _summaryBox(
                                  'Average Income',
                                  '\$${summary['avgIncome'].toStringAsFixed(0)}',
                                  Icons.trending_up,
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Income by Owner',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...byOwner.entries.map((entry) {
                              final owner = entry.key;
                              final total = entry.value['total'] ?? 0.0;
                              final avg = entry.value['average'] ?? 0.0;
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(
                                    'Owner ID: $owner',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      'Average monthly income: \$${avg.toStringAsFixed(2)}'),
                                  trailing: Text(
                                    '\$${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const Divider(),
                      ...grouped.entries.map((entry) {
                        final month = entry.key;
                        final records = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Month: $month',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...records.map((item) => Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    child: ListTile(
                                      title: Text(
                                        'Owner ID: ${item["owner_id"] ?? "N/A"}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Text(
                                        '\$${item["total_income"]?.toStringAsFixed(2) ?? "0.00"}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      }),
                    ],
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

  Widget _summaryBox(String label, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> _computeAllInBackground(List<dynamic> data) {
  final summary = _computeSummary(data);
  final grouped = _groupByMonth(data);
  final byOwner = _computeIncomeByOwner(data);

  return {
    'summary': summary,
    'grouped': grouped,
    'byOwner': byOwner,
  };
}

Map<String, dynamic> _computeSummary(List<dynamic> data) {
  final owners = <String>{};
  double totalIncome = 0;

  for (var item in data) {
    owners.add(item["owner_id"]);
    totalIncome += (item["total_income"] ?? 0.0) as double;
  }

  final avgIncome =
      owners.isEmpty ? 0 : totalIncome / owners.length.toDouble();

  return {
    "ownersCount": owners.length,
    "totalIncome": totalIncome,
    "avgIncome": avgIncome,
  };
}

Map<String, List<Map<String, dynamic>>> _groupByMonth(List<dynamic> data) {
  final Map<String, List<Map<String, dynamic>>> grouped = {};
  for (var item in data) {
    final month = item["month"] ?? "Unknown";
    grouped.putIfAbsent(month, () => []).add(item);
  }
  final sortedKeys = grouped.keys.toList()..sort();
  return {for (var k in sortedKeys) k: grouped[k]!};
}

Map<String, Map<String, double>> _computeIncomeByOwner(List<dynamic> data) {
  final Map<String, List<double>> ownerIncomes = {};
  for (var item in data) {
    final owner = item["owner_id"] ?? "Unknown";
    final income = (item["total_income"] ?? 0.0) as double;
    ownerIncomes.putIfAbsent(owner, () => []).add(income);
  }

  final Map<String, Map<String, double>> result = {};
  ownerIncomes.forEach((owner, incomes) {
    final total = incomes.fold(0.0, (sum, e) => sum + e);
    final average = incomes.isEmpty ? 0.0 : total / incomes.length;
    result[owner] = {"total": total, "average": average};
  });

  final sortedEntries = result.entries.toList()
    ..sort((a, b) => b.value["total"]!.compareTo(a.value["total"]!));
  return {for (var e in sortedEntries) e.key: e.value};
}

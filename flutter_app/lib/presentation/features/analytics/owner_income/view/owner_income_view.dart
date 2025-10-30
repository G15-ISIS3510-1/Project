import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/owner_income_viewmodel.dart';

class OwnerIncomeView extends StatelessWidget {
  const OwnerIncomeView({super.key});

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
      body: viewModel.loading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.ownerIncome.isEmpty
              ? const Center(child: Text('No income data available.'))
              : ListView.builder(
                  itemCount: viewModel.ownerIncome.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.ownerIncome[index];
                    final isGlobal = item["owner_id"] == "ALL";
                    return Card(
                      color: isGlobal ? Colors.green.shade50 : null,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          isGlobal
                              ? '🌍 Global Average'
                              : 'Owner ID: ${item["owner_id"] ?? "N/A"}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          '\$${item["average_monthly_income"] ?? 0}',
                          style: TextStyle(
                            color: isGlobal ? Colors.green : Colors.black,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/credit_cards_viewmodel.dart';

class CreditCardsView extends StatefulWidget {
  const CreditCardsView({super.key});

  @override
  State<CreditCardsView> createState() => _CreditCardsViewState();
}

class _CreditCardsViewState extends State<CreditCardsView> {
  final numberCtrl = TextEditingController();
  final holderCtrl = TextEditingController();
  final expCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreditCardsViewModel>();

    const p24 = 24.0;
    const p16 = 16.0;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(p24, p24, p24, p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      "Payment Methods",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 16),

                    if (vm.cards.isEmpty)
                      const Text("No cards saved yet.",
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),

                    ...vm.cards.map((c) => creditCardBox(c)),
                    const SizedBox(height: 32),

                    const Text(
                      "Add New Card",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    _inputField("Card Number", numberCtrl,
                        keyboard: TextInputType.number, maxLen: 16),

                    const SizedBox(height: 16),
                    _inputField("Card Holder", holderCtrl),

                    const SizedBox(height: 16),
                    _inputField("Expiration (MM/YY)", expCtrl,
                        keyboard: TextInputType.number, maxLen: 5),

                    const SizedBox(height: 16),
                    _inputField("CVV", cvvCtrl,
                        keyboard: TextInputType.number, maxLen: 4),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await vm.addCard(
                            numberCtrl.text,
                            holderCtrl.text,
                            expCtrl.text,
                            cvvCtrl.text,
                          );
                          numberCtrl.clear();
                          holderCtrl.clear();
                          expCtrl.clear();
                          cvvCtrl.clear();
                        },
                        child: const Text("Save Card"),
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: vm.clearAll,
                      child: const Text("Clear All Cards"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl,
      {TextInputType keyboard = TextInputType.text, int? maxLen}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLength: maxLen,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        counterText: "",
      ),
    );
  }

  Widget creditCardBox(Map<String, String> card) {
    final number = card["number"] ?? "";
    final holder = card["holder"] ?? "";
    final exp = card["exp"] ?? "";
    final cvv = card["cvv"] ?? "";

    final masked = number.length >= 4
        ? "**** **** **** ${number.substring(number.length - 4)}"
        : number;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF5145FF), Color(0xFF7B61FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(masked,
              style: const TextStyle(
                  fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniField("Holder", holder),
              _miniField("Exp", exp),
              _miniField("CVV", "*" * cvv.length),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
        Text(value,
            style: const TextStyle(fontSize: 14, color: Colors.white)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../data/credit_card_storage.dart';

class CreditCardsViewModel extends ChangeNotifier {
  List<Map<String, String>> cards = [];
  bool loading = false;
  bool usedCache = true;

  CreditCardsViewModel() {
    loadCards();
  }

  Future<void> loadCards() async {
    loading = true;
    notifyListeners();

    cards = await CreditCardStorage.load();

    loading = false;
    notifyListeners();
  }

  Future<void> addCard(String number, String holder, String exp, String cvv) async {
    final newCard = {
      "number": number,
      "holder": holder,
      "exp": exp,
      "cvv": cvv,
    };

    cards.add(newCard);
    await CreditCardStorage.save(cards);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await CreditCardStorage.clear();
    cards = [];
    notifyListeners();
  }
}

import 'credit_card_storage.dart';

class CreditCardRepository {
  Future<List<Map<String, String>>> loadCards() async {
    return await CreditCardStorage.load();
  }

  Future<void> addCard(Map<String, String> card) async {
    final cards = await CreditCardStorage.load();
    cards.add(card);
    await CreditCardStorage.save(cards);
  }

  Future<void> clearAll() async {
    await CreditCardStorage.clear();
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_app/data/database/daos/kv_dao.dart';

class SuggestedPriceStore {
  final KvDao _kv;
  SuggestedPriceStore(this._kv);

  String _keyFromRequest(Map<String, dynamic> req) {
    // ordena claves para tener determinismo y genera una key compacta
    final sorted = Map<String, dynamic>.fromEntries(
      req.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final payload = jsonEncode(sorted);
    // sin dependencia de hashing: base64 del json
    return 'suggest_price:${base64Encode(Uint8List.fromList(utf8.encode(payload)))}';
  }

  Future<void> save({
    required Map<String, dynamic> request,
    required double price,
    Duration? ttl = const Duration(hours: 6),
  }) async {
    final key = _keyFromRequest(request);
    final now = DateTime.now().toUtc().toIso8601String();
    final body = jsonEncode({
      'price': price,
      'ts': now,
      'ttl_sec': ttl?.inSeconds,
    });
    await _kv.put(key, body);
  }

  Future<double?> load({required Map<String, dynamic> request}) async {
    final key = _keyFromRequest(request);
    final row = await _kv.get(key);
    if (row?.v == null) return null;
    try {
      final m = jsonDecode(row!.v!);
      final price = (m['price'] as num).toDouble();
      final ts = DateTime.parse(m['ts'] as String).toUtc();
      final ttl = m['ttl_sec'] as int?;
      if (ttl == null) return price;
      final exp = ts.add(Duration(seconds: ttl));
      if (DateTime.now().toUtc().isBefore(exp)) return price;
      return null; // expirado
    } catch (_) {
      return null;
    }
  }

  Future<void> invalidate({required Map<String, dynamic> request}) async {
    final key = _keyFromRequest(request);
    await _kv.remove(key);
  }
}

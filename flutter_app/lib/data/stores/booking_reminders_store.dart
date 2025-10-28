import 'dart:convert';
import 'package:flutter_app/data/database/daos/kv_dao.dart';

class BookingRemindersStore {
  final KvDao _kv;
  BookingRemindersStore(this._kv);

  String _key(String userId, int hoursAhead) => 'reminders:$userId:$hoursAhead';

  Future<void> save({
    required String userId,
    required int hoursAhead,
    required Map<String, dynamic> payload, // full JSON {bookings:[...], ...}
    Duration ttl = const Duration(minutes: 10),
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final body = jsonEncode({
      'ts': now,
      'ttl_sec': ttl.inSeconds,
      'data': payload,
    });
    await _kv.put(_key(userId, hoursAhead), body);
  }

  Future<Map<String, dynamic>?> load({
    required String userId,
    required int hoursAhead,
  }) async {
    final row = await _kv.get(_key(userId, hoursAhead));
    if (row?.v == null) return null;
    try {
      final m = jsonDecode(row!.v!);
      final ts = DateTime.parse(m['ts'] as String).toUtc();
      final ttl = m['ttl_sec'] as int?;
      if (ttl == null) return m['data'] as Map<String, dynamic>;
      final exp = ts.add(Duration(seconds: ttl));
      if (DateTime.now().toUtc().isBefore(exp)) {
        return m['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> invalidate({required String userId, required int hoursAhead}) {
    return _kv.remove(_key(userId, hoursAhead));
  }
}

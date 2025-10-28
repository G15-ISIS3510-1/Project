import 'package:shared_preferences/shared_preferences.dart';

/// Guarda el último timestamp leído y/o último message_id por conversación.
/// Claves: lr:<userId>:<conversationId>:ts  y  lr:<userId>:<conversationId>:msg
class LastReadPrefs {
  Future<void> setLastReadAt({
    required String userId,
    required String conversationId,
    required DateTime readAtUtc,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      'lr:$userId:$conversationId:ts',
      readAtUtc.toUtc().toIso8601String(),
    );
  }

  Future<DateTime?> getLastReadAt({
    required String userId,
    required String conversationId,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final s = await sp.getString('lr:$userId:$conversationId:ts');
    if (s == null) return null;
    try {
      return DateTime.parse(s).toUtc();
    } catch (_) {
      return null;
    }
  }

  Future<void> setLastReadMessage({
    required String userId,
    required String conversationId,
    required String messageId,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('lr:$userId:$conversationId:msg', messageId);
  }

  Future<String?> getLastReadMessage({
    required String userId,
    required String conversationId,
  }) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('lr:$userId:$conversationId:msg');
  }
}

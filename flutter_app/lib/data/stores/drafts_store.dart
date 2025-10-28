import 'dart:convert';
import '../database/daos/kv_dao.dart';

/// Guarda borradores por conversación y user.
/// Usa un namespace explícito para evitar colisiones.
/// Value es JSON con { "text": "...", "meta": {...} }
class DraftsStore {
  final KvDao _kv;
  DraftsStore(this._kv);

  String _key(String conversationId, String userId) =>
      'draft:$userId:$conversationId';

  Future<void> save({
    required String conversationId,
    required String userId,
    required String text,
    Map<String, dynamic>? meta,
  }) {
    final payload = jsonEncode({'text': text, 'meta': meta});
    return _kv.put(_key(conversationId, userId), payload);
  }

  Future<String?> loadText({
    required String conversationId,
    required String userId,
  }) async {
    final row = await _kv.get(_key(conversationId, userId));
    if (row?.v == null) return null;
    try {
      final m = jsonDecode(row!.v!);
      return m['text'] as String?;
    } catch (_) {
      return row!.v; // por si guardaste texto plano en algún momento
    }
  }

  Future<Map<String, dynamic>?> loadMeta({
    required String conversationId,
    required String userId,
  }) async {
    final row = await _kv.get(_key(conversationId, userId));
    if (row?.v == null) return null;
    try {
      final m = jsonDecode(row!.v!);
      final meta = m['meta'];
      return meta is Map<String, dynamic> ? meta : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear({
    required String conversationId,
    required String userId,
  }) => _kv.remove(_key(conversationId, userId));
}

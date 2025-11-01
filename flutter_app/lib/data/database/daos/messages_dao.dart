import 'package:drift/drift.dart';
import 'package:flutter_app/data/database/tables/messages_table.dart';
import '../app_database.dart';

part 'messages_dao.g.dart';

@DriftAccessor(tables: [Messages])
class MessagesDao extends DatabaseAccessor<AppDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(AppDatabase db) : super(db);

  Future<void> upsertAll(List<MessagesCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(messages, rows));
  }

  Future<int> clearAll() => delete(messages).go();

  Future<List<MessagesData>> byConversationPaged({
    required String conversationId,
    int limit = 50,
    int offset = 0,
  }) {
    final q =
        (select(messages)
            ..where(
              (t) =>
                  t.conversationId.equals(conversationId) &
                  t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          ..limit(limit, offset: offset);
    return q.get();
  }

  // Opcional; no lo usa el repo ahora mismo
  Future<List<MessagesData>> byThreadPaged({
    required String otherUserId,
    int limit = 50,
    int offset = 0,
  }) {
    final q =
        (select(messages)
            ..where(
              (t) =>
                  (t.senderId.equals(otherUserId) |
                      t.receiverId.equals(otherUserId)) &
                  t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          ..limit(limit, offset: offset);
    return q.get();
  }

  Future<void> softDelete(String messageId) async {
    await (update(messages)..where((t) => t.messageId.equals(messageId))).write(
      const MessagesCompanion(isDeleted: Value(true)),
    );
  }
}

// --------- Quick helpers usados por el repo ----------
extension MessagesQuickX on MessagesDao {
  Future<MessagesData?> lastInConversation(String conversationId) {
    final q = select(messages)
      ..where(
        (t) =>
            t.conversationId.equals(conversationId) & t.isDeleted.equals(false),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(1);
    return q.getSingleOrNull();
  }

  Future<int> unreadCount({
    required String conversationId,
    required String currentUserId,
  }) async {
    final q = select(messages)
      ..where(
        (t) =>
            t.conversationId.equals(conversationId) &
            t.receiverId.equals(currentUserId) &
            t.readAt.isNull() &
            t.isDeleted.equals(false),
      );
    final rows = await q.get();
    return rows.length;
  }
}

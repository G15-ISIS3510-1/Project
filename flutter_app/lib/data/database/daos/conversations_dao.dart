import 'package:drift/drift.dart';
import 'package:flutter_app/data/database/tables/conversations_table.dart';
import '../app_database.dart';

part 'conversations_dao.g.dart';

@DriftAccessor(tables: [Conversations])
class ConversationsDao extends DatabaseAccessor<AppDatabase>
    with _$ConversationsDaoMixin {
  ConversationsDao(AppDatabase db) : super(db);

  Future<void> upsertAll(List<ConversationsCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(conversations, rows));
  }

  Future<int> clearAll() => delete(conversations).go();

  Future<List<ConversationsData>> listPaged({int limit = 50, int offset = 0}) {
    final q =
        (select(conversations)
            ..orderBy([(t) => OrderingTerm.desc(t.lastMessageAt)]))
          ..limit(limit, offset: offset);
    return q.get();
  }

  Future<ConversationsData?> byId(String id) => (select(
    conversations,
  )..where((t) => t.conversationId.equals(id))).getSingleOrNull();
}

extension ConversationsDirectX on ConversationsDao {
  Future<ConversationsData?> findDirect(String a, String b) {
    final low = a.compareTo(b) <= 0 ? a : b;
    final high = a.compareTo(b) <= 0 ? b : a;
    final q = select(conversations)
      ..where((t) => t.userLowId.equals(low) & t.userHighId.equals(high));
    return q.getSingleOrNull();
  }
}

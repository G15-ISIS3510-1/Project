import '../../database/daos/messages_dao.dart';
import '../../database/daos/infra_dao.dart';
import '../../mappers/message_db_mapper.dart';
import '../../models/message_model.dart';

class MessageLocalSource {
  final MessagesDao dao;
  final InfraDao infra;
  MessageLocalSource(this.dao, this.infra);

  Future<List<MessageModel>> getByConversation({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    final rows = await dao.byConversationPaged(
      conversationId: conversationId,
      limit: limit,
      offset: (page - 1) * limit,
    );
    return rows.map((e) => e.toModel()).toList(growable: false);
  }

  Future<List<MessageModel>> getThread(
    String otherUserId, {
    int skip = 0,
    int limit = 50,
  }) async {
    final rows = await dao.byThreadPaged(
      otherUserId: otherUserId,
      limit: limit,
      offset: skip,
    );
    return rows.map((e) => e.toModel()).toList(growable: false);
  }

  Future<void> cacheModels(List<MessageModel> items) async {
    await dao.upsertAll(items.map(messageModelToDb).toList());
  }

  Future<void> softDelete(String messageId) => dao.softDelete(messageId);

  Future<void> checkpoint(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) {
    return infra.saveState(
      entity: 'messages:$conversationId',
      lastFetchAt: DateTime.now().toUtc(),
      pageCursor: (page * limit).toString(),
    );
  }
}

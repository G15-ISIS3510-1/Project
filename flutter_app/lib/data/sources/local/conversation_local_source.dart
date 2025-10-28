import '../../database/daos/conversations_dao.dart';
import '../../database/daos/infra_dao.dart';
import '../../mappers/conversation_db_mapper.dart';
import '../../models/conversation_model.dart' as vm;

class ConversationLocalSource {
  final ConversationsDao dao;
  final InfraDao infra;
  ConversationLocalSource(this.dao, this.infra);

  Future<List<vm.Conversation>> getPage({int page = 1, int limit = 50}) async {
    final rows = await dao.listPaged(limit: limit, offset: (page - 1) * limit);
    return rows.map((e) => e.toModel()).toList(growable: false);
  }

  Future<void> cacheModels(List<vm.Conversation> items) async {
    await dao.upsertAll(items.map(conversationModelToDb).toList());
  }

  Future<void> checkpoint({int page = 1, int limit = 50}) {
    return infra.saveState(
      entity: 'conversations',
      lastFetchAt: DateTime.now().toUtc(),
      pageCursor: (page * limit).toString(),
    );
  }
}

import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/conversations_table.dart';
import '../models/conversation_model.dart'; // ajusta ruta si difiere

extension ConversationRowToModel on ConversationsData {
  Conversation toModel() => Conversation(
    conversationId: conversationId,
    userLowId: userLowId,
    userHighId: userHighId,
    createdAt: createdAt,
    lastMessageAt: lastMessageAt,
  );
}

ConversationsCompanion conversationModelToDb(Conversation c) {
  return ConversationsCompanion(
    conversationId: Value(c.conversationId),
    userLowId: Value(c.userLowId),
    userHighId: Value(c.userHighId),
    createdAt: Value(
      c.createdAt is DateTime
          ? c.createdAt
          : DateTime.parse(c.createdAt as String),
    ),
    lastMessageAt: Value(
      c.lastMessageAt is DateTime
          ? c.lastMessageAt
          : (c.lastMessageAt == null
                ? null
                : DateTime.parse(c.lastMessageAt as String)),
    ),
  );
}

import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/conversations_table.dart';
import '../models/message_model.dart'; // ajusta ruta

extension MessageRowToModel on MessagesData {
  MessageModel toModel() => MessageModel(
    messageId: messageId,
    conversationId: conversationId,
    senderId: senderId,
    receiverId: receiverId,
    content: content,
    meta: meta == null ? null : (jsonDecode(meta!) as Map<String, dynamic>),
    createdAt: createdAt,
    readAt: readAt,
  );
}

MessagesCompanion messageModelToDb(MessageModel m) {
  return MessagesCompanion(
    messageId: Value(m.messageId),
    conversationId: Value(m.conversationId),
    senderId: Value(m.senderId),
    receiverId: Value(m.receiverId),
    content: Value(m.content),
    meta: Value(m.meta == null ? null : jsonEncode(m.meta)),
    createdAt: Value(
      m.createdAt is DateTime
          ? m.createdAt
          : DateTime.parse(m.createdAt as String),
    ),
    readAt: Value(
      m.readAt is DateTime
          ? m.readAt
          : (m.readAt == null ? null : DateTime.parse(m.readAt as String)),
    ),
    isDeleted: const Value(false),
  );
}

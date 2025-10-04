import 'dart:convert';

import 'package:flutter_app/data/models/conversation_model.dart';
import 'package:flutter_app/data/models/message_model.dart';
import 'package:flutter_app/data/sources/remote/chat_remote_source.dart';

abstract class ChatRepository {
  Future<List<Conversation>> listConversations({int skip, int limit});
  Future<List<MessageModel>> getThread(
    String otherUserId, {
    int skip,
    int limit,
    bool onlyUnread,
  });
  Future<void> markThreadAsRead(String otherUserId);
  Future<MessageModel> sendMessage({
    required String receiverId,
    required String content,
    String? conversationId,
    Map<String, dynamic>? meta,
  });
  Future<Conversation> ensureDirectConversation(String otherUserId);

  /// Utilidad: último mensaje del hilo (opcionalmente último recibido por X).
  Future<MessageModel?> getLastMessageInThread(
    String otherUserId, {
    String? onlyReceivedBy,
  });
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatService remote;
  ChatRepositoryImpl({required this.remote});

  @override
  Future<List<Conversation>> listConversations({
    int skip = 0,
    int limit = 100,
  }) async {
    final res = await remote.getConversations(skip: skip, limit: limit);
    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load conversations (${res.statusCode}): ${res.body}',
      );
    }
    final data = jsonDecode(res.body);
    if (data is! List) throw Exception('Unexpected conversations payload');
    return data
        .cast<Map<String, dynamic>>()
        .map((j) => Conversation.fromJson(j))
        .toList();
  }

  @override
  Future<List<MessageModel>> getThread(
    String otherUserId, {
    int skip = 0,
    int limit = 100,
    bool onlyUnread = false,
  }) async {
    final res = await remote.getThread(
      otherUserId,
      skip: skip,
      limit: limit,
      onlyUnread: onlyUnread,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load thread (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(res.body);
    if (data is! List) throw Exception('Unexpected thread payload');
    return data
        .cast<Map<String, dynamic>>()
        .map((j) => MessageModel.fromJson(j))
        .toList();
  }

  @override
  Future<void> markThreadAsRead(String otherUserId) async {
    final res = await remote.markThreadAsRead(otherUserId);
    if (res.statusCode != 200) {
      throw Exception('Failed to mark thread as read: ${res.statusCode}');
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String receiverId,
    required String content,
    String? conversationId,
    Map<String, dynamic>? meta,
  }) async {
    final res = await remote.sendMessage(
      receiverId: receiverId,
      content: content,
      conversationId: conversationId,
      meta: meta,
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception(
        'Failed to send message (${res.statusCode}): ${res.body}',
      );
    }
    final data = jsonDecode(res.body);
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected sendMessage payload');
    }
    return MessageModel.fromJson(data);
  }

  @override
  Future<Conversation> ensureDirectConversation(String otherUserId) async {
    final res = await remote.ensureDirectConversation(otherUserId);
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception(
        'Failed to ensure direct conversation (${res.statusCode}): ${res.body}',
      );
    }
    final data = jsonDecode(res.body);
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected ensureDirectConversation payload');
    }
    return Conversation.fromJson(data);
  }

  @override
  Future<MessageModel?> getLastMessageInThread(
    String otherUserId, {
    String? onlyReceivedBy,
  }) async {
    // Asume que backend ya devuelve DESC (últimos primero)
    final list = await getThread(otherUserId, skip: 0, limit: 20);
    if (list.isEmpty) return null;
    if (onlyReceivedBy == null) return list.first;

    // Busca el último recibido por `onlyReceivedBy`, si no hay, devuelve primero
    for (final m in list) {
      if (m.receiverId == onlyReceivedBy) return m;
    }
    return list.first;
  }
}

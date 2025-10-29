import 'dart:async';                       // Timer, StreamController
import 'dart:convert';
import 'package:flutter/foundation.dart';  // (keep if you later use compute())

import 'package:flutter_app/app/utils/pagination.dart';
import 'package:flutter_app/data/models/conversation_model.dart';
import 'package:flutter_app/data/models/message_model.dart';
import 'package:flutter_app/data/sources/remote/chat_remote_source.dart';

/// Contract for chat operations, including a real-time stream.
abstract class ChatRepository {
  Future<List<Conversation>> listConversations({int skip, int limit});

  Future<List<MessageModel>> getThread(
    String otherUserId, {
    int skip,
    int limit,
    bool onlyUnread,
  });

  /// Continuously emits the thread whenever it changes (polling by default).
  Stream<List<MessageModel>> watchThread(String otherUserId);

  Future<void> markThreadAsRead(String otherUserId);

  Future<MessageModel> sendMessage({
    required String receiverId,
    required String content,
    String? conversationId,
    Map<String, dynamic>? meta,
  });

  Future<Conversation> ensureDirectConversation(String otherUserId);

  Future<String> createThread({
    required String renterId,
    required String hostId,
    required String vehicleId,
    required String bookingId,
    String? initialMessage,
  });

  Future<MessageModel?> getLastMessageInThread(
    String otherUserId, {
    String? onlyReceivedBy,
  });
}

/// Default implementation using REST; adds watchThread() via polling.
class ChatRepositoryImpl implements ChatRepository {
  final ChatService remote;

  final Map<String, StreamController<List<MessageModel>>> _controllers = {};

  ChatRepositoryImpl({required this.remote});

  @override
  Future<String> createThread({
    required String renterId,
    required String hostId,
    required String vehicleId,
    required String bookingId,
    String? initialMessage,
  }) async {
    final payload = {
      'participants': [renterId, hostId],
      'vehicle_id': vehicleId,
      'booking_id': bookingId,
      if (initialMessage != null && initialMessage.isNotEmpty)
        'initial_message': initialMessage,
    };
    final resp = await remote.create(payload);
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Create conversation ${resp.statusCode}: ${resp.body}');
    }
    final j = jsonDecode(resp.body);
    return (j['conversation_id'] ?? j['id']).toString();
  }

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
    final page = parsePaginated<Conversation>(
      res.body,
      (m) => Conversation.fromJson(m),
    );
    return page.items;
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
    final page = parsePaginated<MessageModel>(
      res.body,
      (m) => MessageModel.fromJson(m),
    );
    return page.items;
  }

  @override
  Stream<List<MessageModel>> watchThread(String otherUserId) {
    // Reuse if already created.
    final existing = _controllers[otherUserId];
    if (existing != null) return existing.stream;

    final controller = StreamController<List<MessageModel>>.broadcast();
    _controllers[otherUserId] = controller;

    Future<void> _fetchAndEmit() async {
      try {
        final list = await getThread(otherUserId);
        if (!controller.isClosed) controller.add(list);
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      }
    }

    // Initial fetch.
    _fetchAndEmit();

    // Poll every 5s.
    final timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchAndEmit();
    });

    controller.onCancel = () {
      timer.cancel();
      controller.close();
      _controllers.remove(otherUserId);
    };

    return controller.stream;
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
    final list = await getThread(otherUserId, skip: 0, limit: 20);
    if (list.isEmpty) return null;
    if (onlyReceivedBy == null) return list.first;
    for (final m in list) {
      if (m.receiverId == onlyReceivedBy) return m;
    }
    return list.first;
  }
}

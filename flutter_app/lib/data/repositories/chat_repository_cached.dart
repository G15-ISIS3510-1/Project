import 'dart:async'; // for Stream
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_app/app/utils/net.dart';

import 'package:flutter_app/data/database/app_database.dart';
import 'package:flutter_app/data/database/daos/conversations_dao.dart';
import 'package:flutter_app/data/database/daos/messages_dao.dart';
import 'package:flutter_app/data/mappers/message_db_mapper.dart';

import 'package:flutter_app/data/models/conversation_model.dart';
import 'package:flutter_app/data/models/message_model.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';

import 'package:flutter_app/data/sources/local/conversation_local_source.dart';
import 'package:flutter_app/data/sources/local/message_local_source.dart';
import 'package:flutter_app/data/prefs/last_read_prefs.dart';

/// Decorator with local cache (Drift) for ChatRepository.
class ChatRepositoryCached implements ChatRepository {
  final ChatRepositoryImpl remote; // keeps REST + watchThread() impl
  final ConversationLocalSource convLocal;
  final MessageLocalSource msgLocal;

  final ConversationsDao convDao;
  final MessagesDao msgDao;

  final LastReadPrefs? lastReadPrefs;

  /// Must always return the current user id.
  final String Function() currentUserId;

  ChatRepositoryCached({
    required this.remote,
    required this.convLocal,
    required this.msgLocal,
    required this.convDao,
    required this.msgDao,
    this.lastReadPrefs,
    required this.currentUserId,
  });

  /// Limpia cache local al cerrar sesión (lo llama `_clearAppData`).
  Future<void> clearOnLogout() async {
    try {
      await convDao.clearAll();
    } catch (_) {}
    try {
      await msgDao.clearAll();
    } catch (_) {}
    // Si mantienes caches en memoria, vacíalos aquí también.
  }

  // ----------------------------------------------------------------------
  // Conversations
  // ----------------------------------------------------------------------
  @override
  Future<List<Conversation>> listConversations({
    int skip = 0,
    int limit = 100,
  }) async {
    final cached = await convLocal.getPage(
      page: (skip ~/ limit) + 1,
      limit: limit,
    );
    final hasCached = cached.isNotEmpty;

    if (hasCached && skip == 0) {
      // background refresh
      // ignore: unawaited_futures
      _refreshConversationsInBackground(limit: limit);
      return cached;
    }

    try {
      final remoteList = await remote.listConversations(
        skip: skip,
        limit: limit,
      );
      await convDao.upsertAll(
        remoteList.map(_conversationToDb).toList(growable: false),
      );
      // ignore: unawaited_futures
      convLocal.checkpoint(
        page: (skip ~/ (limit == 0 ? 1 : limit)) + 1,
        limit: limit,
      );
      return remoteList;
    } catch (_) {
      return hasCached ? cached : <Conversation>[];
    }
  }

  Future<void> _refreshConversationsInBackground({required int limit}) async {
    if (!await Net.isOnline()) return;
    try {
      final remoteList = await remote.listConversations(skip: 0, limit: limit);
      await convDao.upsertAll(
        remoteList.map(_conversationToDb).toList(growable: false),
      );
      await convLocal.checkpoint(page: 1, limit: limit);
    } catch (_) {}
  }

  @override
  Future<Conversation> ensureDirectConversation(String otherUserId) async {
    final c = await remote.ensureDirectConversation(otherUserId);
    await convDao.upsertAll([_conversationToDb(c)]);
    return c;
  }

  @override
  Future<String> createThread({
    required String renterId,
    required String hostId,
    required String vehicleId,
    required String bookingId,
    String? initialMessage,
  }) async {
    final id = await remote.createThread(
      renterId: renterId,
      hostId: hostId,
      vehicleId: vehicleId,
      bookingId: bookingId,
      initialMessage: initialMessage,
    );
    return id;
  }

  // ----------------------------------------------------------------------
  // Messages (thread per otherUserId)
  // ----------------------------------------------------------------------

  /// Stream remoto *con persistencia local* sin bloquear el stream.
  @override
  Stream<List<MessageModel>> watchThread(String otherUserId) {
    return remote.watchThread(otherUserId).map((list) {
      // Persist side-effect async
      // ignore: unawaited_futures
      msgDao.upsertAll(list.map(_messageToDb).toList(growable: false));
      return list;
    });
  }

  /// LOCAL-FIRST: último mensaje del hilo desde Drift.
  @override
  Future<MessageModel?> getLastMessageInThread(
    String otherUserId, {
    String? onlyReceivedBy,
  }) async {
    final me = currentUserId();

    final c = await convDao.findDirect(me, otherUserId);
    if (c != null) {
      final last = await msgDao.lastInConversation(c.conversationId);
      if (last != null) {
        final m = last.toModel();
        if (onlyReceivedBy == null || m.receiverId == onlyReceivedBy) {
          return m;
        }
        final page = await msgDao.byConversationPaged(
          conversationId: c.conversationId,
          limit: 50,
          offset: 0,
        );
        for (final row in page) {
          if (row.receiverId == onlyReceivedBy) return row.toModel();
        }
      }
    }

    // fallback remoto
    final remoteLast = await remote.getLastMessageInThread(
      otherUserId,
      onlyReceivedBy: onlyReceivedBy,
    );
    if (remoteLast != null) {
      await msgDao.upsertAll([_messageToDb(remoteLast)]);
    }
    return remoteLast;
  }

  Future<int> getUnreadCountLocal(String conversationId) {
    return msgDao.unreadCount(
      conversationId: conversationId,
      currentUserId: currentUserId(),
    );
  }

  @override
  Future<List<MessageModel>> getThread(
    String otherUserId, {
    int skip = 0,
    int limit = 100,
    bool onlyUnread = false,
  }) async {
    final list = await remote.getThread(
      otherUserId,
      skip: skip,
      limit: limit,
      onlyUnread: onlyUnread,
    );
    await msgDao.upsertAll(list.map(_messageToDb).toList(growable: false));
    return list;
  }

  Future<void> _refreshThreadInBackground({
    required String otherUserId,
    required int limit,
    required bool onlyUnread,
  }) async {
    if (!await Net.isOnline()) return;
    try {
      final list = await remote.getThread(
        otherUserId,
        skip: 0,
        limit: limit,
        onlyUnread: onlyUnread,
      );
      await msgDao.upsertAll(list.map(_messageToDb).toList(growable: false));
      final convId = _firstConversationId(list);
      if (convId != null) {
        await msgLocal.checkpoint(convId, page: 1, limit: limit);
      }
    } catch (_) {}
  }

  @override
  Future<void> markThreadAsRead(String otherUserId) async {
    await remote.markThreadAsRead(otherUserId);
    // Opcional: espejo local si lo soportas
    try {
      final conv = await remote.ensureDirectConversation(otherUserId);
      final convId = conv.conversationId;
      if (convId != null && convId.isNotEmpty) {
        // await msgLocal.markThreadRead(convId, readAt: DateTime.now().toUtc());
      }
    } catch (_) {}
  }

  @override
  Future<MessageModel> sendMessage({
    required String receiverId,
    required String content,
    String? conversationId,
    Map<String, dynamic>? meta,
  }) async {
    final msg = await remote.sendMessage(
      receiverId: receiverId,
      content: content,
      conversationId: conversationId,
      meta: meta,
    );
    await msgDao.upsertAll([_messageToDb(msg)]);
    return msg;
  }

  // -------------------------- Helpers --------------------------
  ConversationsCompanion _conversationToDb(Conversation c) {
    return ConversationsCompanion(
      conversationId: Value(c.conversationId),
      userLowId: Value(c.userLowId),
      userHighId: Value(c.userHighId),
      createdAt: Value(_asDateTime(c.createdAt)),
      lastMessageAt: Value(_asDateTimeOrNull(c.lastMessageAt)),
    );
  }

  MessagesCompanion _messageToDb(MessageModel m) {
    return MessagesCompanion(
      messageId: Value(m.messageId),
      conversationId: Value(m.conversationId),
      senderId: Value(m.senderId),
      receiverId: Value(m.receiverId),
      content: Value(m.content),
      meta: Value(m.meta == null ? null : jsonEncode(m.meta)),
      createdAt: Value(_asDateTime(m.createdAt)),
      readAt: Value(_asDateTimeOrNull(m.readAt)),
      isDeleted: const Value(false),
    );
  }

  String? _firstConversationId(List<MessageModel> list) {
    for (final m in list) {
      if (m.conversationId != null && m.conversationId!.isNotEmpty) {
        return m.conversationId;
      }
    }
    return null;
  }

  DateTime _asDateTime(Object? v) {
    if (v is DateTime) return v.toUtc();
    if (v is String) return DateTime.parse(v).toUtc();
    throw ArgumentError('Invalid DateTime value: $v');
  }

  DateTime? _asDateTimeOrNull(Object? v) {
    if (v == null) return null;
    if (v is DateTime) return v.toUtc();
    if (v is String) return DateTime.parse(v).toUtc();
    throw ArgumentError('Invalid DateTime? value: $v');
  }
}

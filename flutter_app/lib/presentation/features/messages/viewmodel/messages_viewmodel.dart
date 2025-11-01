// lib/presentation/features/messages/viewmodel/messages_viewmodel.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';
import 'package:flutter_app/data/repositories/users_repository.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_app/data/models/conversation_model.dart';
import 'package:flutter_app/data/models/message_model.dart';

import 'package:flutter_app/data/sources/remote/chat_remote_source.dart'; // ChatService

class ConversationUI {
  final String conversationId;
  final String otherUserId;
  final String title;
  final String preview;
  final DateTime? lastAt;
  final int unread;

  ConversationUI({
    required this.conversationId,
    required this.otherUserId,
    required this.title,
    required this.preview,
    required this.lastAt,
    required this.unread,
  });

  ConversationUI copyWith({
    String? conversationId,
    String? otherUserId,
    String? title,
    String? preview,
    DateTime? lastAt,
    int? unread,
  }) {
    return ConversationUI(
      conversationId: conversationId ?? this.conversationId,
      otherUserId: otherUserId ?? this.otherUserId,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      lastAt: lastAt ?? this.lastAt,
      unread: unread ?? this.unread,
    );
  }
}

class MessagesViewModel extends ChangeNotifier {
  final ChatRepository _chat;
  final UsersRepository _users;

  MessagesViewModel({ChatRepository? chat, UsersRepository? users})
    : _chat = chat ?? ChatRepositoryImpl(remote: ChatService()),
      _users = users ?? UsersRepository();

  String _currentUserId = '';
  bool _isHostMode = false;

  // state
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  String _query = '';
  final Map<String, String> _nameCache = {}; // userId -> name
  final Map<String, String> _roleCache = {}; // userId -> role

  List<ConversationUI> _items = [];
  List<ConversationUI> get items {
    if (_query.trim().isEmpty) return _items;
    final q = _query.trim().toLowerCase();
    return _items
        .where((e) {
          return e.title.toLowerCase().contains(q) ||
              e.preview.toLowerCase().contains(q);
        })
        .toList(growable: false);
  }

  void setCurrentUser(String id) {
    _currentUserId = id;
  }

  void setIsHostMode(bool v) {
    _isHostMode = v;
    refresh(); // recargar filtrando según modo
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_currentUserId.isEmpty) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final convs = await _chat.listConversations(skip: 0, limit: 100);
      final ui = <ConversationUI>[];

      for (final c in convs) {
        final otherId = c.otherUserId(_currentUserId);

        // role (con cache)
        final otherRole =
            _roleCache[otherId] ??
            await _users.getUserRole(otherId) ??
            'renter';
        _roleCache[otherId] = otherRole;

        // filtrar por modo
        if (!_roleMatchesForMode(otherRole, _isHostMode)) continue;

        // name (con cache)
        final name =
            _nameCache[otherId] ??
            (await _users.getUserName(otherId) ??
                'User • ${otherId.substring(0, 6)}');
        _nameCache[otherId] = name;

        // último mensaje del hilo (backend devuelve DESC; pedimos limit=1)
        final lastList = await _chat.getThread(otherId, limit: 1);
        final last = lastList.isNotEmpty ? lastList.first : null;

        // cantidad de no leídos (soloUnread)
        final unreadList = await _chat.getThread(
          otherId,
          onlyUnread: true,
          limit: 100,
        );
        final unread = unreadList.length;

        ui.add(
          ConversationUI(
            conversationId: c.conversationId,
            otherUserId: otherId,
            title: name,
            preview: last?.content ?? 'Tap to open chat',
            lastAt: last?.createdAt ?? c.lastMessageAt,
            unread: unread,
          ),
        );
      }

      // orden por recientes
      ui.sort((a, b) {
        final ta = a.lastAt?.millisecondsSinceEpoch ?? 0;
        final tb = b.lastAt?.millisecondsSinceEpoch ?? 0;
        return tb.compareTo(ta);
      });

      _items = ui;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  // limpiar puntito localmente
  void markSeenLocally(int index) {
    if (index < 0 || index >= _items.length) return;
    _items[index] = _items[index].copyWith(unread: 0);
    notifyListeners();
  }

  bool _roleMatchesForMode(String otherRole, bool isHostMode) {
    if (otherRole == 'both') return true;
    if (isHostMode) return otherRole == 'renter';
    return otherRole == 'host';
  }
}

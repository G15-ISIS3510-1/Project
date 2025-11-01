import 'dart:async' show StreamSubscription;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;

import 'package:flutter_app/data/models/message_model.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';
import 'package:flutter_app/data/repositories/users_repository.dart';

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
  final String currentUserId;

  MessagesViewModel({
    required ChatRepository chat,
    required UsersRepository users,
    required this.currentUserId,
  })  : _chat = chat,
        _users = users;

  bool _isHostMode = false;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  String _query = '';
  final Map<String, String> _nameCache = {};
  final Map<String, String> _roleCache = {};

  List<ConversationUI> _items = [];
  List<ConversationUI> get items {
    if (_query.trim().isEmpty) return _items;
    final q = _query.trim().toLowerCase();
    return _items
        .where((e) =>
            e.title.toLowerCase().contains(q) ||
            e.preview.toLowerCase().contains(q))
        .toList(growable: false);
  }

  /// One live subscription per *opened* conversation (to update preview)
  final Map<String, StreamSubscription<List<MessageModel>>> _messageSubs = {};

  bool _disposed = false;

  void setIsHostMode(bool v) {
    _isHostMode = v;
    refresh();
  }

  void setQuery(String q) {
    _query = q;
    _safeNotify();
  }

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    _safeNotify();

    try {
      final convs = await _chat.listConversations(skip: 0, limit: 100);
      if (_disposed) return;

      final ui = <ConversationUI>[];

      for (final c in convs) {
        final otherId = c.otherUserId(currentUserId);

        final otherRole =
            _roleCache[otherId] ?? (await _users.getUserRole(otherId) ?? 'renter');
        _roleCache[otherId] = otherRole;

        if (!_roleMatchesForMode(otherRole, _isHostMode)) continue;

        final name = _nameCache[otherId] ??
            (await _users.getUserName(otherId) ??
                'User • ${otherId.substring(0, 6)}');
        _nameCache[otherId] = name;

        final last = await _chat.getLastMessageInThread(otherId);

        int unread = 0;
        if (_chat is dynamic) {
          try {
            final cached = _chat as dynamic;
            if (c.conversationId.isNotEmpty) {
              unread = await cached.getUnreadCountLocal(c.conversationId);
            }
          } catch (_) {}
        }

        ui.add(
          ConversationUI(
            conversationId: c.conversationId,
            otherUserId: otherId,
            title: name,
            preview: last?.content ?? 'Tap to open chat',
            lastAt: last?.createdAt ?? c.lastMessageAt ?? c.createdAt,
            unread: unread,
          ),
        );

        // Subscribe only when the user opens a thread (see MessagesView).
      }

      ui.sort((a, b) {
        final ta = a.lastAt?.millisecondsSinceEpoch ?? 0;
        final tb = b.lastAt?.millisecondsSinceEpoch ?? 0;
        return tb.compareTo(ta); // newest conversations first in list
      });

      _items = ui;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      _safeNotify();
    }
  }

  // Public forwarder used by Messages view when a tile is opened.
  void subscribeToThread(String otherUserId) => _subscribeToThread(otherUserId);

  void _subscribeToThread(String otherUserId) {
    if (_messageSubs.containsKey(otherUserId)) return;

    _messageSubs[otherUserId] =
        _chat.watchThread(otherUserId).listen((messages) {
      if (_disposed) return;
      final msg = messages.isNotEmpty ? messages.first : null;
      if (msg == null) return;

      final idx = _items.indexWhere((ui) => ui.otherUserId == otherUserId);
      if (idx == -1) return;

      final updated = _items[idx].copyWith(
        preview: msg.content,
        lastAt: msg.createdAt,
      );

      // Avoid “Build scheduled during frame”
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_disposed) return;
        if (idx < 0 || idx >= _items.length) return;
        _items[idx] = updated;
        _safeNotify();
      });
    }, onError: (err, st) {
      // Keep UI stable if backend closes the connection / transient errors.
      if (kDebugMode) {
        // print('watchThread($otherUserId) error: $err');
      }
    }, cancelOnError: false);
  }

  // allow MessagesView to clear badge optimistically
  void markSeenLocally(int index) {
    if (index < 0 || index >= _items.length) return;
    _items[index] = _items[index].copyWith(unread: 0);
    _safeNotify();
  }

  bool _roleMatchesForMode(String otherRole, bool isHostMode) {
    if (otherRole == 'both') return true;
    if (isHostMode) return otherRole == 'renter';
    return otherRole == 'host';
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final sub in _messageSubs.values) {
      sub.cancel();
    }
    _messageSubs.clear();
    super.dispose();
  }
}

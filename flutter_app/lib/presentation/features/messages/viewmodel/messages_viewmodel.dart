import 'package:flutter/foundation.dart';
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
  }) : _chat = chat,
       _users = users;

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
        .where(
          (e) =>
              e.title.toLowerCase().contains(q) ||
              e.preview.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  void setIsHostMode(bool v) {
    _isHostMode = v;
    refresh();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // 1) lista de conversaciones (cache-first en repo)
      final convs = await _chat.listConversations(skip: 0, limit: 100);

      final ui = <ConversationUI>[];

      for (final c in convs) {
        final otherId = c.otherUserId(currentUserId);

        // role (con cache)
        final otherRole =
            _roleCache[otherId] ??
            (await _users.getUserRole(otherId) ?? 'renter');
        _roleCache[otherId] = otherRole;

        // filtrar por modo
        if (!_roleMatchesForMode(otherRole, _isHostMode)) continue;

        // name (con cache)
        final name =
            _nameCache[otherId] ??
            (await _users.getUserName(otherId) ??
                'User • ${otherId.substring(0, 6)}');
        _nameCache[otherId] = name;

        // 2) PREVIEW local-first (usa ChatRepositoryCached.getLastMessageInThread)
        final last = await _chat.getLastMessageInThread(otherId);

        // 3) UNREAD local (si el repo es Cached); si no, 0 o un fallback liviano
        int unread = 0;
        if (_chat is dynamic) {
          try {
            // try-cast seguro en runtime a ChatRepositoryCached sin importar import cycles
            final cached = _chat as dynamic;
            if (c.conversationId.isNotEmpty) {
              unread = await cached.getUnreadCountLocal(c.conversationId);
            }
          } catch (_) {
            // Fallback remoto (pesado): desaconsejado, pero dejar en 0 evita N llamadas
            unread = 0;
          }
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
      }

      // 4) ordenar por recientes
      ui.sort((a, b) {
        final ta = a.lastAt?.millisecondsSinceEpoch ?? 0;
        final tb = b.lastAt?.millisecondsSinceEpoch ?? 0;
        return tb.compareTo(ta);
      });

      _items = ui;
      _loading = false;
      notifyListeners();

      // (Opcional) refresco silencioso de conversaciones
      // ignore: unawaited_futures
      _chat.listConversations(skip: 0, limit: 100);
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  // limpiar badge localmente (al entrar a un chat)
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

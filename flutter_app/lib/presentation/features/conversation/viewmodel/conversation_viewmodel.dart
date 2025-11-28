// lib/presentation/features/conversation/viewmodel/conversation_viewmodel.dart
// lib/presentation/features/conversation/viewmodel/conversation_viewmodel.dart
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;

import 'package:flutter_app/data/models/message_model.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';

enum ConvStatus { loading, ready, error }

class ConversationViewModel extends ChangeNotifier {
  final ChatRepository repo;
  final String currentUserId;
  final String otherUserId;
  final String? conversationId;

  static const int _maxMessages = 200; // keep last N to reduce memory/CPU

  ConversationViewModel({
    required this.repo,
    required this.currentUserId,
    required this.otherUserId,
    required this.conversationId,
  });

  final List<MessageModel> _messages = [];
  UnmodifiableListView<MessageModel> get messages =>
      UnmodifiableListView(_messages);

  ConvStatus _status = ConvStatus.loading;
  ConvStatus get status => _status;

  String? _error;
  String? get error => _error;

  bool _didChange = false;
  bool get didChange => _didChange;

  StreamSubscription<List<MessageModel>>? _sub;
  bool _disposed = false;

  Future<void> init() async {
    _status = ConvStatus.loading;
    _error = null;
    _safeNotify();

    try {
      // Initial load
      final initial = await repo.getThread(otherUserId, skip: 0, limit: 100);
      if (_disposed) return;
      _resetMessages(initial);
      _status = ConvStatus.ready;
      _safeNotify();

      // "Realtime" updates via polling/stream
      _sub?.cancel();
      _sub = repo.watchThread(otherUserId).listen((list) {
        if (_disposed) return;
        // Update after frame to avoid build conflicts
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (_disposed) return;
          _resetMessages(list);
          _safeNotify();
        });
      }, onError: (e) {
        if (_disposed) return;
        _error = e.toString();
        _status = ConvStatus.error;
        _safeNotify();
      });
    } catch (e) {
      _error = e.toString();
      _status = ConvStatus.error;
      _safeNotify();
    }
  }

  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    // Optimistic append so the message shows immediately.
    final temp = MessageModel(
      messageId: 'temp-${DateTime.now().microsecondsSinceEpoch}',
      senderId: currentUserId,
      receiverId: otherUserId,
      content: t,
      createdAt: DateTime.now(),
      conversationId: conversationId,
      meta: const {'optimistic': true},
      readAt: null,
    );
    _messages.add(temp);
    if (_messages.length > _maxMessages) {
      _messages.removeRange(0, _messages.length - _maxMessages);
    }
    _safeNotify();
    final optimisticId = temp.messageId;

    try {
      final sent = await repo.sendMessage(
        receiverId: otherUserId,
        content: t,
        conversationId: conversationId,
      );
      _didChange = true; // parent list can refresh on pop
      // Replace optimistic with server response (id/timestamp correct).
      _messages.removeWhere((m) => m.messageId == optimisticId);
      _upsertMessage(sent);
      _safeNotify();
      // Stream will refresh messages; no extra fetch needed.
    } catch (e) {
      // Remove optimistic on error
      _messages.removeWhere((m) => m.messageId == optimisticId);
      _error = e.toString();
      _status = ConvStatus.error;
      _safeNotify();
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void _resetMessages(List<MessageModel> incoming) {
    // Keep optimistic messages that are not yet present in incoming
    final incomingIds = incoming.map((m) => m.messageId).toSet();
    final optimistic = _messages.where((m) {
      final isTemp = m.messageId.startsWith('temp-') ||
          (m.meta != null && m.meta?['optimistic'] == true);
      return isTemp && !incomingIds.contains(m.messageId);
    });

    _messages
      ..clear()
      ..addAll(incoming)
      ..addAll(optimistic);

    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (_messages.length > _maxMessages) {
      _messages.removeRange(0, _messages.length - _maxMessages);
    }
  }

  void _upsertMessage(MessageModel m) {
    final idx = _messages.indexWhere((x) => x.messageId == m.messageId);
    if (idx >= 0) {
      _messages[idx] = m;
    } else {
      _messages.add(m);
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (_messages.length > _maxMessages) {
        _messages.removeRange(0, _messages.length - _maxMessages);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}

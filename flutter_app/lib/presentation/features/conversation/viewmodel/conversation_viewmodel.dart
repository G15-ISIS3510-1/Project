// lib/presentation/features/conversation/viewmodel/conversation_viewmodel.dart
import 'dart:async';
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

  ConversationViewModel({
    required this.repo,
    required this.currentUserId,
    required this.otherUserId,
    required this.conversationId,
  });

  final List<MessageModel> _messages = [];
  List<MessageModel> get messages => List.unmodifiable(_messages);

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
      _messages
        ..clear()
        ..addAll(initial);
      _status = ConvStatus.ready;
      _safeNotify();

      // "Realtime" updates via polling/stream
      _sub?.cancel();
      _sub = repo.watchThread(otherUserId).listen((list) {
        if (_disposed) return;
        // Update after frame to avoid build conflicts
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (_disposed) return;
          _messages
            ..clear()
            ..addAll(list);
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
    try {
      await repo.sendMessage(
        receiverId: otherUserId,
        content: t,
        conversationId: conversationId,
      );
      _didChange = true; // parent list can refresh on pop
      // Stream will refresh messages; no extra fetch needed.
    } catch (e) {
      _error = e.toString();
      _status = ConvStatus.error;
      _safeNotify();
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}

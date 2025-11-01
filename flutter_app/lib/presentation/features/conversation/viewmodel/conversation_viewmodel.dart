import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/models/message_model.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';

enum ConvStatus { loading, ready, error }

class ConversationViewModel extends ChangeNotifier {
  final ChatRepository _repo;
  final String currentUserId;
  final String otherUserId;
  final String? conversationId;

  ConversationViewModel({
    required ChatRepository repo,
    required this.currentUserId,
    required this.otherUserId,
    this.conversationId,
  }) : _repo = repo;

  ConvStatus _status = ConvStatus.loading;
  ConvStatus get status => _status;

  String? _error;
  String? get error => _error;

  final List<MessageModel> _messages = [];
  List<MessageModel> get messages => List.unmodifiable(_messages);

  bool _didChange = false;
  bool get didChange => _didChange;

  // paginación sencilla
  int _skip = 0;
  final int _limit = 50;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> init() async {
    await load(reset: true);
    await markAsRead();
  }

  Future<void> load({bool reset = false}) async {
    try {
      if (reset) {
        _status = ConvStatus.loading;
        _error = null;
        _messages.clear();
        _skip = 0;
        _hasMore = true;
        notifyListeners();
      }

      final list = await _repo.getThread(
        otherUserId,
        skip: _skip,
        limit: _limit,
        onlyUnread: false,
      );

      // backend → DESC; UI → antiguos arriba
      final orderedAsc = list.reversed.toList();

      if (reset) {
        _messages
          ..clear()
          ..addAll(orderedAsc);
      } else {
        _messages.addAll(orderedAsc);
      }

      _hasMore = list.length == _limit;
      if (_hasMore) _skip += _limit;

      _status = ConvStatus.ready;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _status = ConvStatus.error;
      notifyListeners();
    }
  }

  Future<void> send(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;
    try {
      final m = await _repo.sendMessage(
        receiverId: otherUserId,
        content: content,
        conversationId: conversationId,
      );
      _messages.add(
        m,
      ); // ya viene con timestamps; lo ponemos al final (parte baja)
      _didChange = true;
      notifyListeners();
    } catch (_) {
      // podrías exponer error si lo necesitas
    }
  }

  Future<void> markAsRead() async {
    try {
      await _repo.markThreadAsRead(otherUserId);
      _didChange = true;
    } catch (_) {}
  }
}

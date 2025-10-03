import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/messages/messages.dart';
import '../features/conversations/conversations.dart';

class ChatApi {
  final String baseUrl;
  final String token; // Bearer
  ChatApi({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // --- Conversations ---
  Future<List<Conversation>> getConversations({
    int skip = 0,
    int limit = 100,
  }) async {
    final uri = Uri.parse('$baseUrl/conversations?skip=$skip&limit=$limit');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to load conversations (${res.statusCode})');
    }
    final List data = json.decode(res.body) as List;
    return data.map((e) => Conversation.fromJson(e)).toList();
  }

  // --- Messages (thread) ---
  Future<List<MessageModel>> getThread(
    String otherUserId, {
    int skip = 0,
    int limit = 100,
    bool onlyUnread = false,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/messages/thread/$otherUserId?skip=$skip&limit=$limit${onlyUnread ? '&only_unread=true' : ''}',
    );
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to load thread (${res.statusCode})');
    }
    final List data = json.decode(res.body) as List;
    return data.map((e) => MessageModel.fromJson(e)).toList();
  }

  Future<void> markThreadAsRead(
    String otherUserId, {
    required String readerId,
  }) async {
    final uri = Uri.parse('$baseUrl/messages/thread/$otherUserId/read');
    final res = await http.post(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to mark thread as read');
    }
  }

  Future<MessageModel> sendMessage({
    required String receiverId,
    required String content,
    String? conversationId, // opcional (el backend la resuelve si no llega)
    Map<String, dynamic>? meta,
  }) async {
    final uri = Uri.parse('$baseUrl/messages/');
    final body = json.encode({
      'receiver_id': receiverId,
      'content': content,
      if (conversationId != null) 'conversation_id': conversationId,
      if (meta != null) 'meta': meta,
    });
    final res = await http.post(uri, headers: _headers, body: body);
    if (res.statusCode != 201) {
      throw Exception(
        'Failed to send message (${res.statusCode}): ${res.body}',
      );
    }
    return MessageModel.fromJson(json.decode(res.body));
  }

  // Opcional: garantizar/crear conversación directa y devolverla
  Future<Conversation> ensureDirectConversation(String otherUserId) async {
    final uri = Uri.parse('$baseUrl/conversations/direct');
    final res = await http.post(
      uri,
      headers: _headers,
      body: json.encode({'other_user_id': otherUserId}),
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception(
        'Failed to ensure direct conversation (${res.statusCode})',
      );
    }
    return Conversation.fromJson(json.decode(res.body));
  }
}

extension ChatApiHelpers on ChatApi {
  /// Devuelve el último mensaje del hilo con otherUserId.
  /// Si [onlyReceivedBy] viene, intenta devolver el último mensaje recibido por ese user;
  /// si no existe, devuelve el último del hilo.
  Future<MessageModel?> getLastMessageInThread(
    String otherUserId, {
    String? onlyReceivedBy,
  }) async {
    final msgs = await getThread(
      otherUserId,
      skip: 0,
      limit: 20,
    ); // ya viene DESC
    if (msgs.isEmpty) return null;

    if (onlyReceivedBy != null) {
      final rx = msgs.firstWhere(
        (m) => m.receiverId == onlyReceivedBy,
        orElse: () => msgs.first,
      );
      return rx;
    }
    return msgs.first;
  }
}

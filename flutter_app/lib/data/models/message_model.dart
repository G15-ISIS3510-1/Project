class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final String? conversationId;
  final Map<String, dynamic>? meta;
  final DateTime createdAt;
  final DateTime? readAt;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.conversationId,
    this.meta,
    this.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    messageId: json['message_id'] as String,
    senderId: json['sender_id'] as String,
    receiverId: json['receiver_id'] as String,
    content: json['content'] as String,
    conversationId: json['conversation_id'] as String?,
    meta: json['meta'] as Map<String, dynamic>?,
    createdAt: DateTime.parse(json['created_at'] as String),
    readAt: json['read_at'] != null
        ? DateTime.parse(json['read_at'] as String)
        : null,
  );
}

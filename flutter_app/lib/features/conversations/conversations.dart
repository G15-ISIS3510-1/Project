class Conversation {
  final String conversationId;
  final String userLowId;
  final String userHighId;
  final String? title;
  final DateTime createdAt;
  final DateTime? lastMessageAt;

  Conversation({
    required this.conversationId,
    required this.userLowId,
    required this.userHighId,
    required this.createdAt,
    this.lastMessageAt,
    this.title,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    conversationId: json['conversation_id'] as String,
    userLowId: json['user_low_id'] as String,
    userHighId: json['user_high_id'] as String,
    title: json['title'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    lastMessageAt: json['last_message_at'] != null
        ? DateTime.parse(json['last_message_at'] as String)
        : null,
  );

  String otherUserId(String currentUserId) {
    // Par ordenado: el "otro" es el distinto a ti.
    if (currentUserId == userLowId) return userHighId;
    return userLowId;
  }
}

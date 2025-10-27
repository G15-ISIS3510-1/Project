// lib/presentation/features/conversation/view/conversation_route.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/data/repositories/chat_repository.dart';
import 'package:flutter_app/presentation/features/conversation/view/conversation_view.dart';
import 'package:flutter_app/presentation/features/conversation/viewmodel/conversation_viewmodel.dart';

class ConversationRoute extends StatelessWidget {
  final String currentUserId;
  final String otherUserId;
  final String? conversationId;

  const ConversationRoute({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    this.conversationId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConversationViewModel>(
      create: (_) => ConversationViewModel(
        repo: context.read<ChatRepository>(),
        currentUserId: currentUserId,
        otherUserId: otherUserId,
        conversationId: conversationId,
      )..init(), // si tu VM necesita precargar mensajes
      child: ConversationPage(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
        conversationId: conversationId,
      ),
    );
  }
}

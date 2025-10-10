import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/data/models/message_model.dart';
import 'package:flutter_app/presentation/features/conversation/viewmodel/conversation_viewmodel.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';

class ConversationPage extends StatefulWidget {
  final String otherUserId;
  final String? conversationId;

  const ConversationPage({
    super.key,
    required this.otherUserId,
    this.conversationId,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (ctx) {
        final vm = ConversationViewModel(
          repo: ctx.read<ChatRepository>(),
          currentUserId: ctx.read<AuthProvider>().userId ?? '',
          otherUserId: widget.otherUserId,
          conversationId: widget.conversationId,
        );
        vm.init();
        return vm;
      },
      child: Consumer<ConversationViewModel>(
        builder: (_, vm, __) {
          _jumpToBottom();

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) Navigator.pop(context, vm.didChange);
            },
            child: Scaffold(
              backgroundColor: colorScheme.background,
              appBar: AppBar(
                title: Text('Conversation', style: textTheme.titleMedium),
                backgroundColor: colorScheme.surface,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context, vm.didChange),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: switch (vm.status) {
                      ConvStatus.loading => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      ConvStatus.error => Center(
                        child: Text(vm.error ?? 'Error'),
                      ),
                      ConvStatus.ready => ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        itemCount: vm.messages.length,
                        itemBuilder: (_, i) {
                          final m = vm.messages[i];
                          final isMe = m.senderId == vm.currentUserId;
                          return _Bubble(
                            m: m,
                            isMe: isMe,
                            isDark: isDark,
                            scheme: colorScheme,
                          );
                        },
                      ),
                    },
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Escribe un mensaje…',
                                hintStyle: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceVariant,
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                  borderSide: BorderSide(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              final t = _controller.text;
                              _controller.clear();
                              vm.send(t);
                            },
                            icon: const Icon(Icons.send),
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final MessageModel m;
  final bool isMe;
  final bool isDark;
  final ColorScheme scheme;

  const _Bubble({
    required this.m,
    required this.isMe,
    required this.isDark,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe
        ? scheme.primary
        : isDark
        ? const Color(0xFF1E2634) // gris oscuro para modo noche
        : const Color(0xFFF2F3F5); // gris claro modo día

    final textColor = isMe
        ? scheme.onPrimary
        : isDark
        ? Colors.white
        : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          m.content,
          style: TextStyle(color: textColor, fontSize: 15, height: 1.25),
        ),
      ),
    );
  }
}

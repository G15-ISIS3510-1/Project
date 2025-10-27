import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/message_model.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';
import 'package:flutter_app/presentation/features/conversation/viewmodel/conversation_viewmodel.dart';
import 'package:provider/provider.dart';

class ConversationPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String? conversationId; // opcional

  const ConversationPage({
    super.key,
    required this.currentUserId,
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

    return ChangeNotifierProvider(
      create: (ctx) => ConversationViewModel(
        repo: ctx.read<ChatRepository>(), // ✅ instancia real del repositorio
        currentUserId: widget.currentUserId, // ✅ IDs desde los argumentos
        otherUserId: widget.otherUserId,
        conversationId: widget.conversationId,
      )..init(), // 👈 inicializa la conversación al crear el VM
      builder: (context, _) {
        return Consumer<ConversationViewModel>(
          builder: (_, vm, __) {
            _jumpToBottom();

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) Navigator.pop(context, vm.didChange);
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Conversation', style: textTheme.titleMedium),
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
                            final isMe = m.senderId == widget.currentUserId;
                            return _Bubble(m: m, isMe: isMe);
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
                                decoration: const InputDecoration(
                                  hintText: 'Escribe un mensaje…',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(14),
                                    ),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
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
                              color: const Color(0xFF007AFF),
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
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  final MessageModel m;
  final bool isMe;
  const _Bubble({required this.m, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF007AFF) : const Color(0xFFF2F3F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          m.content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

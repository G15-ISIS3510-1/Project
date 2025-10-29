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

  /// When true we auto-stick to bottom (new messages push the view).
  bool _stickToBottom = true;

  /// To detect new messages and decide autoscroll.
  int _lastRenderedCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    // If you're within 80 px of the bottom, consider "at bottom".
    if (!_scrollCtrl.hasClients) return;
    final distanceFromBottom =
        _scrollCtrl.position.maxScrollExtent - _scrollCtrl.position.pixels;
    final atBottom = distanceFromBottom <= 80.0;
    if (atBottom != _stickToBottom) {
      setState(() => _stickToBottom = atBottom);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    final target = _scrollCtrl.position.maxScrollExtent;
    if (animated) {
      _scrollCtrl.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } else {
      _scrollCtrl.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChangeNotifierProvider(
      create: (ctx) => ConversationViewModel(
        repo: ctx.read<ChatRepository>(),
        currentUserId: widget.currentUserId,
        otherUserId: widget.otherUserId,
        conversationId: widget.conversationId,
      )..init(),
      builder: (context, _) {
        return Consumer<ConversationViewModel>(
          builder: (_, vm, __) {
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
                        ConvStatus.ready => _buildMessages(vm),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14)),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                onSubmitted: (_) => _handleSend(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _handleSend,
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

  Widget _buildMessages(ConversationViewModel vm) {
    // Oldest -> Newest (so newest is at the bottom)
    final msgs = [...vm.messages]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // If message count grew and we are near bottom, auto-scroll.
    final newCount = msgs.length;
    if (newCount != _lastRenderedCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_stickToBottom) _scrollToBottom(animated: true);
      });
      _lastRenderedCount = newCount;
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: msgs.length,
      itemBuilder: (_, i) {
        final m = msgs[i];
        final isMe = m.senderId == widget.currentUserId;
        return _Bubble(m: m, isMe: isMe);
      },
    );
  }

  void _handleSend() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    _controller.clear();

    // We consider the user "at bottom" after sending.
    _stickToBottom = true;
    _scrollToBottom(animated: true);

    // Send
    context.read<ConversationViewModel>().send(t);
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

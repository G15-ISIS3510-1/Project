// lib/presentation/features/conversation/view/conversation_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/data/sources/remote/chat_remote_source.dart';
import 'package:flutter_app/data/models/message_model.dart';


class ConversationPage extends StatefulWidget {
  final ChatApi api;
  final String currentUserId;
  final String otherUserId;
  final String? conversationId; // opcional

  const ConversationPage({
    super.key,
    required this.api,
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
  bool _loading = true;
  List<MessageModel> _messages = [];
  bool _marked = false;
  bool _didChange = false;

  @override
  void initState() {
    super.initState();
    _load();
    _markAsRead();
  }

  Future<void> _load() async {
    try {
      final msgs = await widget.api.getThread(
        widget.otherUserId,
        skip: 0,
        limit: 50,
      );

      final ordered = msgs.reversed.toList();
      await widget.api.markThreadAsRead(
        widget.otherUserId,
        readerId: widget.currentUserId,
      );

      setState(() {
        _messages = ordered; // más antiguos arriba
        _loading = false;
      });
      // marcar como leído lo recibido
      await widget.api.markThreadAsRead(
        widget.otherUserId,
        readerId: widget.currentUserId,
      );
      _jumpToBottom();
    } catch (e) {
      setState(() => _loading = false);
      // puedes mostrar snackbar
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  Future<void> _markAsRead() async {
    try {
      final n = await widget.api.markThreadAsRead(
        widget.otherUserId,
        readerId: widget.currentUserId,
      );
      _marked = true;
      _didChange = true;
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    try {
      // Si tienes conversationId úsala; si no, el backend la asegura
      final msg = await widget.api.sendMessage(
        receiverId: widget.otherUserId,
        content: text,
        conversationId: widget.conversationId,
      );
      setState(() {
        _messages.add(msg);
      });
      _didChange = true;
      _jumpToBottom();
    } catch (e) {
      // snackbar error
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: false, // dejamos que pueda cerrar
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Si Flutter no hizo el pop automáticamente, lo haces tú
          Navigator.pop(context, _didChange);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Conversation', style: textTheme.titleMedium),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // back del AppBar: también devolvemos el flag
              Navigator.pop(context, _didChange);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) {
                        final m = _messages[i];
                        final isMe = m.senderId == widget.currentUserId;
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: const BoxConstraints(maxWidth: 320),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color(0xFF007AFF)
                                  : const Color(0xFFF2F3F5),
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
                      },
                    ),
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
                            borderRadius: BorderRadius.all(Radius.circular(14)),
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
                      onPressed: _send,
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
  }
}

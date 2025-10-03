// lib/messages/messages_view.dart  (tu archivo con cambios MINIMOS)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/Home/conversation_view.dart';
import '../../data/chat_api.dart';
import '../../data/users_api.dart';
import '../home/widgets/search_bar.dart' as qovo;
import '../../host_mode_provider.dart';

class MessagesView extends StatefulWidget {
  final ChatApi api;
  final String currentUserId;

  const MessagesView({
    super.key,
    required this.api,
    required this.currentUserId,
  });

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView>
    with AutomaticKeepAliveClientMixin<MessagesView> {
  @override
  bool get wantKeepAlive => true;

  static const double _p24 = 24;
  late Future<List<_ConversationUI>> _future;

  late final UsersApi _usersApi;
  final Map<String, String> _nameCache = {}; // userId -> name
  final Map<String, String> _roleCache =
      {}; // userId -> role (renter/host/both)

  @override
  void initState() {
    super.initState();
    _usersApi = UsersApi(baseUrl: widget.api.baseUrl, token: widget.api.token);
    _future = _loadConversations();

    // 👇 mueve el listener aquí
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HostModeProvider>().addListener(_onModeChanged);
    });
  }

  void _onModeChanged() {
    if (!mounted) return;
    _roleCache.clear(); // opcional
    setState(() {
      _future = _loadConversations(); // ✅ callback retorna void
    });
  }

  @override
  void dispose() {
    // 👇 remueve con seguridad
    try {
      context.read<HostModeProvider>().removeListener(_onModeChanged);
    } catch (_) {}
    super.dispose();
  }

  Future<String?> _getRole(String userId) async {
    final cached = _roleCache[userId];
    if (cached != null) return cached;

    final role = await _usersApi.getUserRole(
      userId,
    ); // 'renter' | 'host' | 'both' | null
    if (role != null && role.isNotEmpty) {
      _roleCache[userId] = role;
    }
    return role; // puede ser null
  }

  bool _roleMatchesForMode({
    required String otherRole,
    required bool isHostMode,
  }) {
    // Si el otro tiene BOTH, se permite en ambos modos
    if (otherRole == 'both') return true;
    // Host Mode: ver mensajes con renters
    if (isHostMode) return otherRole == 'renter';
    // Renter Mode: ver mensajes con hosts
    return otherRole == 'host';
  }

  Future<List<_ConversationUI>> _loadConversations() async {
    final isHostMode = context.read<HostModeProvider>().isHostMode;
    final list = await widget.api.getConversations();
    final items = <_ConversationUI>[];

    for (final c in list) {
      final otherId = c.otherUserId(widget.currentUserId);

      // rol del otro usuario
      final otherRole = await _getRole(otherId) ?? 'renter';

      // Filtrar por rol según el modo actual
      if (!_roleMatchesForMode(otherRole: otherRole, isHostMode: isHostMode)) {
        continue;
      }

      // nombre (con caché)
      final name =
          _nameCache[otherId] ??
          (await _usersApi.getUserName(otherId) ??
              'User • ${otherId.substring(0, 6)}');
      _nameCache[otherId] = name;

      // último mensaje del hilo
      final lastList = await widget.api.getThread(otherId, limit: 1);
      final last = lastList.isNotEmpty ? lastList.first : null;

      // no leídos
      final unreadMsgs = await widget.api.getThread(
        otherId,
        onlyUnread: true,
        limit: 100,
      );
      final unread = unreadMsgs.length;

      items.add(
        _ConversationUI(
          conversationId: c.conversationId,
          otherUserId: otherId,
          title: name,
          preview: last?.content ?? 'Tap to open chat',
          lastAt: last?.createdAt ?? c.lastMessageAt,
          unread: unread,
        ),
      );
    }

    // Más recientes primero
    items.sort((a, b) {
      final ta = a.lastAt?.millisecondsSinceEpoch ?? 0;
      final tb = b.lastAt?.millisecondsSinceEpoch ?? 0;
      return tb.compareTo(ta);
    });

    return items;
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return SafeArea(
      top: true,
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(_p24, _p24, _p24, 12),
              child: Column(
                children: [
                  Center(
                    child: Transform.scale(
                      scaleY: 0.82,
                      child: Text(
                        'QOVO',
                        style: text.displaySmall?.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          // usa onBackground según tema
                          color: scheme.onBackground.withOpacity(0.95),
                          letterSpacing: -7.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  qovo.SearchBar(),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: FutureBuilder<List<_ConversationUI>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Error loading conversations: ${snap.error}'),
                  );
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('No conversations yet'),
                  );
                }

                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 0.8,
                    thickness: 0.8,
                    color: Color(0xFFFAFAFA),
                  ),
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return _ConversationTile(
                      title: it.title,
                      subtitle: it.preview,
                      time: _formatTime(it.lastAt),
                      unreadDot: it.unread > 0,
                      onTap: () async {
                        setState(() {
                          items[i] = items[i].copyWith(unread: 0);
                        });

                        await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => ConversationPage(
                              api: widget.api,
                              currentUserId: widget.currentUserId,
                              otherUserId: it.otherUserId,
                              conversationId: it.conversationId,
                            ),
                          ),
                        );

                        if (!mounted) return;
                        setState(() {
                          _future = _loadConversations(); // ✅
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: 76 + 12 + bottomInset + 8),
          ),
        ],
      ),
    );
  }
}

class _ConversationUI {
  final String conversationId;
  final String otherUserId;
  final String title;
  final String preview;
  final DateTime? lastAt;
  final int unread;

  _ConversationUI({
    required this.conversationId,
    required this.otherUserId,
    required this.title,
    required this.preview,
    required this.lastAt,
    required this.unread,
  });
  _ConversationUI copyWith({
    String? conversationId,
    String? otherUserId,
    String? title,
    String? preview,
    DateTime? lastAt,
    int? unread,
  }) {
    return _ConversationUI(
      conversationId: conversationId ?? this.conversationId,
      otherUserId: otherUserId ?? this.otherUserId,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      lastAt: lastAt ?? this.lastAt,
      unread: unread ?? this.unread,
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool unreadDot;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unreadDot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, color: Color(0xFFB8BDC7)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: text.bodySmall?.copyWith(
                    fontSize: 13,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (unreadDot)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

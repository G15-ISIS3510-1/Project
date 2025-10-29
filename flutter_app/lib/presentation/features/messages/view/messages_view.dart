// lib/presentation/features/messages/view/messages_view.dart
import 'dart:math' as MainSize;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/presentation/common_widgets/search_bar.dart'
    as qovo;
import 'package:flutter_app/presentation/features/app_shell/viewmodel/host_mode_provider.dart';

import 'package:flutter_app/presentation/features/messages/viewmodel/messages_viewmodel.dart';

// 👇 we need these two imports for the chat detail screen
import 'package:flutter_app/presentation/features/conversation/view/conversation_view.dart';
import 'package:flutter_app/presentation/features/conversation/viewmodel/conversation_viewmodel.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';

class MessagesView extends StatefulWidget {
  final String currentUserId;

  const MessagesView({super.key, required this.currentUserId});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView>
    with AutomaticKeepAliveClientMixin<MessagesView> {
  DateTime _lastRefresh = DateTime.fromMillisecondsSinceEpoch(0);
  bool _canRefresh() =>
      DateTime.now().difference(_lastRefresh) > const Duration(seconds: 1);

  @override
  bool get wantKeepAlive => true;

  static const double _p24 = 24;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<MessagesViewModel>();

      // ✅ establecer modo actual en el VM y cargar
      vm.setIsHostMode(context.read<HostModeProvider>().isHostMode);
      vm.refresh();

      // ✅ escuchar cambios de modo
      context.read<HostModeProvider>().addListener(_onModeChanged);
    });
  }

  void _onModeChanged() {
    if (!mounted) return;
    final isHost = context.read<HostModeProvider>().isHostMode;
    context.read<MessagesViewModel>().setIsHostMode(isHost);
  }

  @override
  void dispose() {
    try {
      context.read<HostModeProvider>().removeListener(_onModeChanged);
    } catch (_) {}
    super.dispose();
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
      child: Consumer<MessagesViewModel>(
        builder: (_, vm, __) {
          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              // Refrescar solo con overscroll real, arrastre del usuario y umbral suficiente
              if (n is OverscrollNotification &&
                  n.dragDetails != null && // ignora frames balísticos / rebotes
                  n.overscroll < -120 && // pull-down >= 80 px (ajusta a gusto)
                  n.metrics.pixels <= n.metrics.minScrollExtent &&
                  !vm.loading &&
                  _canRefresh()) {
                _lastRefresh = DateTime.now();
                vm.refresh();
                return true; // consumir para evitar doble trigger
              }
              return false;
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Header
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
                                color: scheme.onBackground.withOpacity(0.95),
                                letterSpacing: -7.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        qovo.SearchBar(
                          onChanged:
                              vm.setQuery, // filtro local por nombre/preview
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista / estados
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (_) {
                      if (vm.loading) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (vm.error != null) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'Error loading conversations: ${vm.error}',
                          ),
                        );
                      }
                      final items = vm.items;
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
                              vm.markSeenLocally(i);
                              final didChange = await Navigator.of(context)
                                  .push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) {
                                        final parentCtx = context;
                                        return ChangeNotifierProvider<
                                          ConversationViewModel
                                        >(
                                          create: (_) => ConversationViewModel(
                                            repo: parentCtx
                                                .read<ChatRepository>(),
                                            currentUserId: widget.currentUserId,
                                            otherUserId: it.otherUserId,
                                            conversationId: it.conversationId,
                                          )..init(),
                                          child: ConversationPage(
                                            currentUserId: widget.currentUserId,
                                            otherUserId: it.otherUserId,
                                            conversationId: it.conversationId,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                              if (!mounted) return;
                              if (didChange == true) vm.refresh();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // Spacer para bottom bar
                SliverToBoxAdapter(
                  child: SizedBox(height: 76 + 12 + bottomInset + 8),
                ),
              ],
            ),
          );
        },
      ),
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

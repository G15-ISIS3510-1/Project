import 'package:flutter/material.dart';
import '../home/widgets/search_bar.dart' as qovo;

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView>
    with AutomaticKeepAliveClientMixin<MessagesView> {
  @override
  bool get wantKeepAlive => true;

  static const double _p24 = 24;

  final _items = const [
    MessageItem(
      name: 'Julian Dasilva',
      preview: 'Hi Julian!',
      time: '12:00',
      unread: 2,
    ),
    MessageItem(
      name: 'Alex Morgan',
      preview: 'Your booking is confirmed',
      time: '09:45',
      unread: 1,
    ),
    MessageItem(
      name: 'Sam Carter',
      preview: 'Thanks!',
      time: 'Yesterday',
      unread: 0,
    ),
    MessageItem(
      name: 'Nina López',
      preview: 'Can we change the time?',
      time: 'Mon',
      unread: 3,
    ),
    MessageItem(
      name: 'Chris Kim',
      preview: 'See you soon',
      time: 'Sun',
      unread: 0,
    ),
    MessageItem(
      name: 'Taylor Reed',
      preview: 'Sent the docs ✅',
      time: 'Fri',
      unread: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: true,
      bottom: false,
      child: CustomScrollView(
        slivers: [
          // Header + Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(_p24, _p24, _p24, 12),
              child: Column(
                children: [
                  Center(
                    child: Transform.scale(
                      scaleY: 0.82,
                      child: const Text(
                        'QOVO',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
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

          // Message list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: _p24),
            sliver: SliverList.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(
                height: 0.8, // 👈 mínimo
                thickness: 0.8,
                color: Color(0xFFFAFAFA), // 👈 stroke sutil entre cards
              ),
              itemBuilder: (_, i) => MessageCard(item: _items[i]),
            ),
          ),

          // espacio para el bottom bar del shell
          SliverToBoxAdapter(
            child: SizedBox(height: 76 + 12 + bottomInset + 8),
          ),
        ],
      ),
    );
  }
}

/// Model
class MessageItem {
  final String name;
  final String preview;
  final String time; // ya formateado (p.ej. "12:00", "Yesterday")
  final int unread; // 0 = sin badge
  const MessageItem({
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
  });
}

/// Card
class MessageCard extends StatelessWidget {
  final MessageItem item;
  const MessageCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {},
      child: Padding(
        // 👇 más padding arriba/abajo
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar redondo
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle, // 👈 redondo
              ),
              child: const Icon(Icons.image_outlined, color: Color(0xFFB8BDC7)),
            ),
            const SizedBox(width: 14),

            // Name + preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
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
                    item.preview,
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

            // Hora + badge
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.time,
                  style: text.bodySmall?.copyWith(
                    fontSize: 13,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (item.unread > 0)
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${item.unread}',
                      style: text.labelMedium?.copyWith(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
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

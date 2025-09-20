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
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Avatar placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.image_outlined, color: Color(0xFFB8BDC7)),
            ),
            const SizedBox(width: 12),

            // Name + preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // name + time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.time,
                        style: text.bodySmall?.copyWith(
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Unread badge (si > 0)
            if (item.unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${item.unread}',
                  style: text.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TripItem {
  final String title;
  final String date;
  final String? imageUrl; // NEW (optional)

  const TripItem({
    required this.title,
    required this.date,
    this.imageUrl,
  });
}

class TripCard extends StatelessWidget {
  final TripItem item;
  const TripCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;

    Widget trailingThumb() {
      // If we have an image URL, use a cached image widget (LRU mem+disk)
      if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 48,
            height: 48,
            child: CachedNetworkImage(
              imageUrl: item.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF1E2634)
                    : scheme.surfaceVariant,
                child: Icon(Icons.image_outlined, color: scheme.onSurfaceVariant),
              ),
              errorWidget: (_, __, ___) => Container(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF1E2634)
                    : scheme.surfaceVariant,
                child: Icon(Icons.broken_image_outlined,
                    color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        );
      }

      // Fallback icon box (no URL available)
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF1E2634)
              : scheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.image_outlined, color: scheme.onSurfaceVariant),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          item.title,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            item.date,
            style: text.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: trailingThumb(),
      ),
    );
    }
}

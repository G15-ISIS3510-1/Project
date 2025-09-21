import 'package:flutter/material.dart';

class TripItem {
  final String title;
  final String date;
  const TripItem({required this.title, required this.date});
}

class TripCard extends StatelessWidget {
  final TripItem item;
  const TripCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          item.title,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            item.date,
            style: text.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.image_outlined, color: Color(0xFFB8BDC7)),
        ),
      ),
    );
  }
}

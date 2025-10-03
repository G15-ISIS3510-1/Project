import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  final List<String> items;
  const CategoryChips({super.key, required this.items});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  int? selected = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = (int i) => selected == i;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          for (int i = 0; i < widget.items.length; i++) ...[
            ChoiceChip(
              label: Text(widget.items[i]),
              selected: isSelected(i),
              onSelected: (v) => setState(() => selected = v ? i : null),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selectedColor: scheme.primaryContainer,
              backgroundColor: scheme.surfaceVariant,
              labelStyle: TextStyle(
                color: isSelected(i)
                    ? scheme.onPrimaryContainer
                    : scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

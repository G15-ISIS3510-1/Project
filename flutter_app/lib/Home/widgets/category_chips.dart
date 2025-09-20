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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          for (int i = 0; i < widget.items.length; i++) ...[
            ChoiceChip(
              label: Text(widget.items[i]),
              selected: selected == i,
              onSelected: (v) => setState(() => selected = v ? i : null),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selectedColor: const Color(0xFF4DA2FF),
              labelStyle: TextStyle(
                color: selected == i ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: const Color(0xFFF3F4F6),
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

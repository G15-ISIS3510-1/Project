import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  final List<String> items;

  /// Callback cuando cambia la selección.
  /// Envía el label seleccionado; o `null` si se deselecciona.
  final ValueChanged<String?>? onSelected;

  /// Índice seleccionado inicial (0 por defecto). Usa `null` para sin selección.
  final int? initialIndex;

  const CategoryChips({
    super.key,
    required this.items,
    this.onSelected,
    this.initialIndex = 0,
  });

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  int? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    bool isSelected(int i) => selected == i;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          for (int i = 0; i < widget.items.length; i++) ...[
            ChoiceChip(
              label: Text(widget.items[i]),
              selected: isSelected(i),
              onSelected: (v) {
                setState(() => selected = v ? i : null);
                widget.onSelected?.call(v ? widget.items[i] : null);
              },
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

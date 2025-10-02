import 'package:flutter/material.dart';

enum TripFilter { all, booked, history }

class TripFilterSegmented extends StatelessWidget {
  final TripFilter value;
  final ValueChanged<TripFilter> onChanged;

  const TripFilterSegmented({
    super.key,
    required this.value,
    required this.onChanged,
  });

  int get _index => switch (value) {
    TripFilter.all => 0,
    TripFilter.booked => 1,
    TripFilter.history => 2,
  };

  // Mapea 0,1,2 → -1, 0, 1
  double get _alignX => (_index / 2) * 2 - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final bgPill = theme.brightness == Brightness.dark
        ? const Color(0xFF1C2230)
        : scheme.surfaceVariant;
    final knobColor = theme.cardColor;
    final labelColor = scheme.onSurfaceVariant;
    final activeColor = scheme.primary;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgPill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        height: 40,
        child: Stack(
          children: [
            // Indicador deslizante único
            AnimatedAlign(
              alignment: Alignment(_alignX, 0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: FractionallySizedBox(
                widthFactor: 1 / 3,
                heightFactor: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: knobColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          theme.brightness == Brightness.dark ? 0.28 : 0.06,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Filas de botones
            Row(
              children: [
                _SegButton(
                  label: 'All',
                  selected: _index == 0,
                  activeColor: activeColor,
                  labelColor: labelColor,
                  onTap: () => onChanged(TripFilter.all),
                ),
                _SegButton(
                  label: 'Booked',
                  selected: _index == 1,
                  activeColor: activeColor,
                  labelColor: labelColor,
                  onTap: () => onChanged(TripFilter.booked),
                ),
                _SegButton(
                  label: 'History',
                  selected: _index == 2,
                  activeColor: activeColor,
                  labelColor: labelColor,
                  onTap: () => onChanged(TripFilter.history),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color labelColor;

  const _SegButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: selected ? activeColor : labelColor,
    );

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Center(child: Text(label, style: style)),
      ),
    );
  }
}

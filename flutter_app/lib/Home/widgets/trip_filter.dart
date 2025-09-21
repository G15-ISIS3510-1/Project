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
    const bg = Color(0xFFF2F2F7);
    const blue = Color(0xFF007AFF);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.hardEdge, // evita “sangres” fuera del pill
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
                widthFactor: 1 / 3, // 3 segmentos
                heightFactor: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Filas de botones (sin fondo por item)
            Row(
              children: [
                _SegButton(
                  label: 'All',
                  selected: _index == 0,
                  onTap: () => onChanged(TripFilter.all),
                ),
                _SegButton(
                  label: 'Booked',
                  selected: _index == 1,
                  onTap: () => onChanged(TripFilter.booked),
                ),
                _SegButton(
                  label: 'History',
                  selected: _index == 2,
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
  const _SegButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF007AFF);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? blue : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

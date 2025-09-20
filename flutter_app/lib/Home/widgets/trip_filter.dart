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

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF2F2F7);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(child: _seg(context, 'All', TripFilter.all)),
          const SizedBox(width: 4),
          Expanded(child: _seg(context, 'Booked', TripFilter.booked)),
          const SizedBox(width: 4),
          Expanded(child: _seg(context, 'History', TripFilter.history)),
        ],
      ),
    );
  }

  Widget _seg(BuildContext context, String label, TripFilter me) {
    final selected = value == me;
    const blue = Color(0xFF007AFF);
    return GestureDetector(
      onTap: () => onChanged(me),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
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

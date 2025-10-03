import 'dart:ui';
import 'package:flutter/material.dart';

class BottomBarItem {
  final IconData icon;
  final String label;
  const BottomBarItem(this.icon, this.label);
}

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<BottomBarItem> items;

  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onTap,
  }) : assert(items.length >= 2);

  double _alignmentXFor(int index) {
    if (items.length == 1) return 0;
    return (index / (items.length - 1)) * 2 - 1; // [-1,1]
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glassTop = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.white.withOpacity(0.30);
    final glassBottom = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.12);
    final glassBorder = isDark
        ? Colors.white.withOpacity(0.14)
        : Colors.white.withOpacity(0.20);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // --- Glass container ---
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [glassTop, glassBottom],
                    ),
                    border: Border.all(color: glassBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.30 : 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- MAGNIFIER ---
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedAlign(
                  alignment: Alignment(_alignmentXFor(currentIndex), -0.2),
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipOval(
                          child: RawMagnifier(
                            size: const Size(76, 76),
                            magnificationScale: 1.15,
                            focalPointOffset: const Offset(0, -6),
                            child: const SizedBox.shrink(),
                          ),
                        ),
                        IgnorePointer(
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.55),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.35 : 0.10,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- Items ---
            SizedBox(
              height: 76,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _GlassItem(
                        item: items[i],
                        active: i == currentIndex,
                        onTap: () => onTap?.call(i),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassItem extends StatelessWidget {
  final BottomBarItem item;
  final bool active;
  final VoidCallback? onTap;
  const _GlassItem({required this.item, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: active ? 1.18 : 1.0,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              child: Icon(item.icon, size: 22, color: scheme.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

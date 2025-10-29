import 'package:flutter/material.dart';

class CarCard extends StatelessWidget {
  final String? imageUrl; // ⬅️ NUEVO
  final String title;
  final double rating;
  final String transmission;
  final double price;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const CarCard({
    super.key,
    required this.title,
    required this.rating,
    required this.transmission,
    required this.price,
    this.imageUrl, // ⬅️ NUEVO
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    final BorderRadius topRadius = const BorderRadius.vertical(
      top: Radius.circular(16),
    );

    Widget _placeholder() => Container(
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: topRadius,
      ),
      child: Icon(
        Icons.image_outlined,
        size: 56,
        color: scheme.onSurfaceVariant,
      ),
    );

    Widget _image() {
      if (imageUrl == null || imageUrl!.isEmpty) return _placeholder();

      return ClipRRect(
        borderRadius: topRadius,
        child: Stack(
          children: [
            // Fondo por si tarda en cargar
            Positioned.fill(child: Container(color: scheme.surfaceVariant)),
            Positioned.fill(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                // indicador de carga
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                                (progress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                // fallback en error
                errorBuilder: (ctx, err, st) => _placeholder(),
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap, // ⬅️ toda la tarjeta navegable
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            children: [
              // Imagen
              Stack(
                children: [
                  AspectRatio(aspectRatio: 16 / 9, child: _image()),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: InkWell(
                      onTap:
                          onFavoriteToggle, // ⬅️ corazón usa onFavoriteToggle
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: scheme.surface.withOpacity(0.90),
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 20,
                          color: isFavorite
                              ? Colors.redAccent
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título + rating
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star_rate_rounded,
                          size: 18,
                          color: Colors.amber.shade600,
                        ),
                        Text(
                          rating.toStringAsFixed(1),
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Transmisión + Precio
                    Row(
                      children: [
                        Text(
                          transmission,
                          style: text.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _asCurrency(price),
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _asCurrency(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final thousands = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '\$$thousands.${parts[1]}';
  }
}

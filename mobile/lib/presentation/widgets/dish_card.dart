import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/plato_model.dart';

class DishCard extends StatelessWidget {
  final PlatoModel plato;
  final VoidCallback? onTapLocal;

  const DishCard({
    super.key,
    required this.plato,
    this.onTapLocal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen o placeholder del plato
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 75,
              height: 75,
              color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
              child: plato.fullImagenUrl.isNotEmpty
                  ? Image.network(
                      plato.fullImagenUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.fastfood_rounded, color: AppColors.textMuted, size: 28),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.fastfood_rounded, color: AppColors.textMuted, size: 28),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Información del plato
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        plato.nombre,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      plato.formattedPrecio,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.accentBlue : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (plato.descripcion.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    plato.descripcion,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),

                // Badges: Plato del Día o Local asociado
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (plato.esPlatoDelDia)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('⭐', style: TextStyle(fontSize: 10)),
                            SizedBox(width: 3),
                            Text(
                              'Plato del Día',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (plato.localNombre != null && plato.localNombre!.isNotEmpty)
                      Semantics(
                        label: 'Ver local ${plato.localNombre}',
                        button: true,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            if (onTapLocal != null) {
                              HapticFeedback.lightImpact();
                              onTapLocal!();
                            }
                          },
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 28),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.chipBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.storefront_rounded,
                                  size: 13,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  plato.localNombre!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.accentBlue : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

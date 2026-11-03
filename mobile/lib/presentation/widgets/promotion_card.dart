import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/promocion_model.dart';

class PromotionCard extends StatelessWidget {
  final PromocionModel promocion;
  final VoidCallback onTap;
  final bool isCompact;

  const PromotionCard({
    super.key,
    required this.promocion,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final discount = promocion.porcentajeDescuento;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.border.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner o imagen de la promo
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Container(
                      height: isCompact ? 100 : 120,
                      width: double.infinity,
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.primaryLight,
                      child: promocion.fullImagenUrl.isNotEmpty
                          ? Image.network(
                              promocion.fullImagenUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPromoPlaceholder(),
                            )
                          : _buildPromoPlaceholder(),
                    ),
                  ),

                  // Tag de Promoción / Oferta de Hoy
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 11)),
                          SizedBox(width: 3),
                          Text(
                            'OFERTA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Badge de porcentaje de descuento
                  if (discount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-$discount%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Contenido
              Padding(
                padding: EdgeInsets.all(isCompact ? 10 : 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del Local
                    if (promocion.localNombre != null &&
                        promocion.localNombre!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              promocion.localNombre!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.accentBlue
                                    : AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (promocion.campusNombre.isNotEmpty)
                            Text(
                              promocion.campusNombre,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 4),

                    // Título de la Promoción
                    Text(
                      promocion.titulo,
                      style: TextStyle(
                        fontSize: isCompact ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Descripción
                    if (promocion.descripcion.isNotEmpty)
                      Text(
                        promocion.descripcion,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: isCompact ? 6 : 10),

                    // Precios y días válidos
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              promocion.formattedPrecioPromocional,
                              style: TextStyle(
                                fontSize: isCompact ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.accentBlue
                                    : AppColors.primary,
                              ),
                            ),
                            if (promocion.formattedPrecioOriginal != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                promocion.formattedPrecioOriginal!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.chipBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            promocion.etiquetaDias,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }

  Widget _buildPromoPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🍔🍟🥤', style: TextStyle(fontSize: 28)),
          SizedBox(height: 4),
          Text(
            'Promoción Universitaria',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

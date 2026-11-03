import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/plato_model.dart';
import '../../data/models/promocion_model.dart';

/// Elemento del carrusel "Hoy": una oferta vigente o un plato del día.
class NovedadHoy {
  final bool esOferta;
  final String titulo;
  final String? localNombre;
  final String imagenUrl;
  final String precio;
  final String? precioOriginal;
  final int porcentajeDescuento;
  final String localId;

  const NovedadHoy({
    required this.esOferta,
    required this.titulo,
    required this.localNombre,
    required this.imagenUrl,
    required this.precio,
    required this.localId,
    this.precioOriginal,
    this.porcentajeDescuento = 0,
  });

  factory NovedadHoy.fromPromocion(PromocionModel p) => NovedadHoy(
        esOferta: true,
        titulo: p.titulo,
        localNombre: p.localNombre,
        imagenUrl: p.fullImagenUrl,
        precio: p.formattedPrecioPromocional,
        precioOriginal: p.formattedPrecioOriginal,
        porcentajeDescuento: p.porcentajeDescuento,
        localId: p.localId,
      );

  factory NovedadHoy.fromPlato(PlatoModel p) => NovedadHoy(
        esOferta: false,
        titulo: p.nombre,
        localNombre: p.localNombre,
        imagenUrl: p.fullImagenUrl,
        precio: p.formattedPrecio,
        localId: p.localId,
      );

  /// Intercala ofertas y platos del día para que ambos se vean en las primeras tarjetas.
  static List<NovedadHoy> intercalar(
    List<PromocionModel> promociones,
    List<PlatoModel> platos, {
    int maximo = 8,
  }) {
    final resultado = <NovedadHoy>[];
    var i = 0;
    while (resultado.length < maximo && (i < promociones.length || i < platos.length)) {
      if (i < promociones.length) resultado.add(NovedadHoy.fromPromocion(promociones[i]));
      if (resultado.length < maximo && i < platos.length) {
        resultado.add(NovedadHoy.fromPlato(platos[i]));
      }
      i++;
    }
    return resultado;
  }
}

class NovedadHoyCard extends StatelessWidget {
  final NovedadHoy novedad;
  final VoidCallback onTap;

  const NovedadHoyCard({
    super.key,
    required this.novedad,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final acento = isDark ? AppColors.accentBlue : AppColors.primary;

    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 96,
                      width: double.infinity,
                      color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                      child: novedad.imagenUrl.isNotEmpty
                          ? Image.network(
                              novedad.imagenUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: novedad.esOferta ? AppColors.error : AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        novedad.esOferta ? '🔥 Oferta' : '⭐ Del día',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: novedad.esOferta ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  if (novedad.porcentajeDescuento > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${novedad.porcentajeDescuento}%',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      novedad.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    if (novedad.localNombre != null && novedad.localNombre!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          novedad.localNombre!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          novedad.precio,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: acento,
                          ),
                        ),
                        if (novedad.precioOriginal != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            novedad.precioOriginal!,
                            style: TextStyle(
                              fontSize: 11.5,
                              decoration: TextDecoration.lineThrough,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                            ),
                          ),
                        ],
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

  Widget _placeholder() => const Center(
        child: Icon(Icons.restaurant_rounded, color: AppColors.textMuted, size: 30),
      );
}

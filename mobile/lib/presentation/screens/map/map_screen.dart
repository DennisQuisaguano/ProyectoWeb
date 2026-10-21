import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/smooth_page_route.dart';
import '../../../data/models/local_model.dart';
import '../../providers/local_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/star_rating_display.dart';
import '../../../shared/widgets/puni_mascot.dart';
import '../local_detail/local_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LocalModel? _selectedPinLocal;

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final local = context.watch<LocalProvider>();

    final centerLat = location.referenceLatitude;
    final centerLng = location.referenceLongitude;
    final initialCenter = LatLng(centerLat, centerLng);

    final markers = <Marker>[];

    // Marcador interactivo de la posición del estudiante: Puni explorador (segunda.png)
    final userLat = location.currentPosition?.latitude ?? location.referenceLatitude;
    final userLng = location.currentPosition?.longitude ?? location.referenceLongitude;

    markers.add(
      Marker(
        point: LatLng(userLat, userLng),
        width: 68,
        height: 78,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  location.currentPosition != null
                      ? '📍 ¡Aquí estás tú con Puni!'
                      : '📍 Puni en ${location.campusNombre} (Activa GPS para tu ubicación exacta)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Pulso de geolocalización suave bajo los pies de Puni
              Positioned(
                bottom: 2,
                child: Container(
                  width: 32,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    borderRadius: const BorderRadius.all(Radius.elliptical(32, 12)),
                  ),
                ),
              ),
              // Mascota oficial interactiva Puni con mapa y pin (segunda.png)
              const Positioned(
                bottom: 6,
                child: PuniMascot(
                  mood: PuniMood.discovering,
                  size: 64,
                  shadow: false,
                ),
              ),
              // Badge de identificación "Tú"
              Positioned(
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Text(
                    'TÚ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Marcadores de los locales gastronómicos
    for (final l in local.locales) {
      if (l.latitud == 0.0 && l.longitud == 0.0) continue;
      final isSelected = _selectedPinLocal?.id == l.id;

      markers.add(
        Marker(
          point: LatLng(l.latitud, l.longitud),
          width: isSelected ? 54 : 44,
          height: isSelected ? 54 : 44,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPinLocal = l;
              });
              _mapController.move(LatLng(l.latitud, l.longitud), 16.5);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : AppColors.primary,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(isSelected ? 0.35 : 0.15),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  l.categoriaIcono,
                  style: TextStyle(fontSize: isSelected ? 24 : 18),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Mapa Interactivo OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 16.0,
              minZoom: 12.0,
              maxZoom: 18.5,
              onTap: (_, __) {
                if (_selectedPinLocal != null) {
                  setState(() => _selectedPinLocal = null);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.uta.sistemagastronomico',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Header Flotante Soft UI: Campus y total de locales
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.border.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : AppColors.primaryDark.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurface
                            : AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.accentBlue
                            : AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        location.campusNombre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurface
                            : AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBorder
                              : AppColors.primaryLight,
                        ),
                      ),
                      child: Text(
                        '${local.locales.length} opciones',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.accentBlue
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botón flotante para recentrar en mi ubicación
          Positioned(
            right: 16,
            bottom: _selectedPinLocal != null ? 210 : 28,
            child: FloatingActionButton.small(
              heroTag: 'recenter_gps_modern',
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.accentBlue
                  : AppColors.primary,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onPressed: () {
                if (location.currentPosition != null) {
                  _mapController.move(
                    LatLng(location.currentPosition!.latitude, location.currentPosition!.longitude),
                    16.5,
                  );
                } else {
                  location.fetchUserLocation();
                  _mapController.move(
                    LatLng(location.referenceLatitude, location.referenceLongitude),
                    16.0,
                  );
                }
              },
              child: const Icon(Icons.my_location_rounded),
            ),
          ),

          // Tarjeta Flotante Soft UI al seleccionar un Pin de local
          if (_selectedPinLocal != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset: Offset.zero,
                child: _buildLocalSelectedCard(context, _selectedPinLocal!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocalSelectedCard(BuildContext context, LocalModel l) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : AppColors.primaryDark.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.primaryLight),
                ),
                child: Center(
                  child: Text(l.categoriaIcono, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.nombre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        StarRatingDisplay(rating: l.calificacionPromedio, totalReviews: l.totalResenas),
                        const SizedBox(width: 8),
                        Text(
                          l.estaAbierto ? '• Abierto' : '• Cerrado',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: l.estaAbierto ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                onPressed: () => setState(() => _selectedPinLocal = null),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (l.distanciaEnMetros != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.near_me_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    l.formattedDistance,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.directions_walk_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    l.formattedWalkingTime,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  SmoothPageRoute(page: LocalDetailScreen(localId: l.id, initialLocal: l)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ver Menú y Reseñas →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

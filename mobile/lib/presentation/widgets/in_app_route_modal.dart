import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/routing_service.dart';
import '../../shared/widgets/puni_mascot.dart';

class InAppRouteModal extends StatefulWidget {
  final LatLng userPoint;
  final LatLng localPoint;
  final String localNombre;
  final String categoriaIcono;

  const InAppRouteModal({
    super.key,
    required this.userPoint,
    required this.localPoint,
    required this.localNombre,
    required this.categoriaIcono,
  });

  static Future<void> show({
    required BuildContext context,
    required LatLng userPoint,
    required LatLng localPoint,
    required String localNombre,
    required String categoriaIcono,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InAppRouteModal(
        userPoint: userPoint,
        localPoint: localPoint,
        localNombre: localNombre,
        categoriaIcono: categoriaIcono,
      ),
    );
  }

  @override
  State<InAppRouteModal> createState() => _InAppRouteModalState();
}

class _InAppRouteModalState extends State<InAppRouteModal> {
  final MapController _mapController = MapController();
  RouteInfo? _route;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final route = await RoutingService.getWalkingRoute(
      start: widget.userPoint,
      end: widget.localPoint,
    );

    if (mounted) {
      setState(() {
        _route = route;
        _isLoading = false;
      });

      // Ajustar la cámara a la ruta con animación suave
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitRoute();
      });
    }
  }

  void _fitRoute() {
    if (_route == null || _route!.points.isEmpty) return;
    try {
      final bounds = LatLngBounds.fromPoints([
        widget.userPoint,
        widget.localPoint,
        ..._route!.points,
      ]);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
        ),
      );
    } catch (_) {}
  }

  void _centerUser() {
    HapticFeedback.selectionClick();
    _mapController.move(widget.userPoint, 16.5);
  }

  void _centerDestination() {
    HapticFeedback.selectionClick();
    _mapController.move(widget.localPoint, 16.5);
  }

  void _openGoogleMapsOptional() async {
    HapticFeedback.lightImpact();
    final lat = widget.localPoint.latitude;
    final lng = widget.localPoint.longitude;
    final uri = Uri.parse('google.navigation:q=$lat,$lng&mode=w');
    final webUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final centerLat = (widget.userPoint.latitude + widget.localPoint.latitude) / 2;
    final centerLng = (widget.userPoint.longitude + widget.localPoint.longitude) / 2;

    return Container(
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de agarre y Encabezado
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.directions_walk_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ruta a ${widget.localNombre}',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isLoading
                                ? 'Calculando mejor camino por calles...'
                                : '${_route?.formattedDistance ?? ''} • ${_route?.formattedWalkingTime ?? ''}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.accentBlue : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.8),

          // Mapa Interactivo con Ruta por Calles
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(centerLat, centerLng),
                    initialZoom: 15.5,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'ec.edu.uta.gastronomia',
                    ),
                    // Línea continua por las calles reales
                    if (_route != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _route!.points,
                            strokeWidth: 5.5,
                            color: const Color(0xFF0284C7),
                            borderStrokeWidth: 2.2,
                            borderColor: Colors.white,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        // Marcador de salida: Puni explorador
                        Marker(
                          point: widget.userPoint,
                          width: 54,
                          height: 64,
                          child: const PuniMascot(
                            mood: PuniMood.discovering,
                            size: 52,
                            shadow: true,
                          ),
                        ),
                        // Marcador de destino: Local gastronómico
                        Marker(
                          point: widget.localPoint,
                          width: 48,
                          height: 48,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.categoriaIcono,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Indicador de carga si la ruta está calculándose
                if (_isLoading)
                  Positioned(
                    top: 14,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Trazando mejor camino...',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Botones flotantes de control rápido sobre el mapa
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'btnFitRoute',
                        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                        foregroundColor: isDark ? AppColors.accentBlue : AppColors.primary,
                        elevation: 4,
                        onPressed: _fitRoute,
                        tooltip: 'Ver ruta completa',
                        child: const Icon(Icons.fullscreen_rounded, size: 22),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'btnCenterUser',
                        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                        foregroundColor: isDark ? AppColors.accentBlue : AppColors.primary,
                        elevation: 4,
                        onPressed: _centerUser,
                        tooltip: 'Mi ubicación',
                        child: const Icon(Icons.my_location_rounded, size: 20),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'btnCenterDest',
                        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                        foregroundColor: isDark ? AppColors.accentBlue : AppColors.primary,
                        elevation: 4,
                        onPressed: _centerDestination,
                        tooltip: 'Destino',
                        child: const Icon(Icons.storefront_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tarjeta inferior de navegación directa in-app
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 0.8,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('🚶‍♂️', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  _route?.formattedDistance ?? 'Calculando...',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _route?.formattedWalkingTime ?? '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sigue la línea azul trazada por las calles',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_new_rounded, size: 14),
                        label: const Text('Maps', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _openGoogleMapsOptional,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.explore_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        'Ajustar Vista a Toda la Ruta',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _fitRoute();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

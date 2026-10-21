import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'location_service.dart';

class RouteInfo {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final bool isActualRoadRoute;

  RouteInfo({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.isActualRoadRoute,
  });

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    } else {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  String get formattedWalkingTime {
    final minutes = (durationSeconds / 60).round();
    if (minutes <= 1) return '1 min a pie';
    return '$minutes min a pie';
  }
}

class RoutingService {
  /// Obtiene la ruta a pie real trazada por calles y senderos usando OpenStreetMap / OSRM
  static Future<RouteInfo> getWalkingRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/foot/'
      '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final double distance = (route['distance'] as num).toDouble();
          final double duration = (route['duration'] as num).toDouble();
          final List coords = route['geometry']['coordinates'];

          final List<LatLng> points = coords.map((c) {
            final lng = (c[0] as num).toDouble();
            final lat = (c[1] as num).toDouble();
            return LatLng(lat, lng);
          }).toList();

          if (points.isNotEmpty) {
            return RouteInfo(
              points: points,
              distanceMeters: distance,
              durationSeconds: duration,
              isActualRoadRoute: true,
            );
          }
        }
      }
    } catch (_) {
      // Fallback a línea directa si no hay internet o el servidor OSRM no responde
    }

    final fallbackDist = LocationService.calculateDistanceMeters(
      startLatitude: start.latitude,
      startLongitude: start.longitude,
      endLatitude: end.latitude,
      endLongitude: end.longitude,
    );
    final fallbackDuration = fallbackDist / 1.2;

    return RouteInfo(
      points: [start, end],
      distanceMeters: fallbackDist,
      durationSeconds: fallbackDuration,
      isActualRoadRoute: false,
    );
  }
}

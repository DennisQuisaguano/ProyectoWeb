import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Determina la posición actual del usuario solicitando permisos de forma amigable.
  /// Si el usuario rechaza los permisos o el GPS está desactivado, retorna null
  /// permitiendo que la aplicación continúe funcionando sin bloquear al estudiante.
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Obtener posición con precisión balanceada para ahorrar batería
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Calcula la distancia en metros entre dos coordenadas geográficas
  static double calculateDistanceMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Formatea la distancia de manera legible (ej. "350 m" o "1.4 km")
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Estima el tiempo a pie caminando (~80 metros por minuto = 4.8 km/h)
  static String estimateWalkingTime(double meters) {
    if (meters <= 0) return 'A pocos pasos';
    final minutes = (meters / 80).round();
    if (minutes <= 1) return '~1 min a pie';
    if (minutes < 60) return '~$minutes min a pie';
    final hours = minutes ~/ 60;
    final remainingMin = minutes % 60;
    return '~$hours h $remainingMin min a pie';
  }
}

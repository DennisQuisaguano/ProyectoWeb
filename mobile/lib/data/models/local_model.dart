import '../../core/constants/api_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/location_service.dart';

class LocalModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String direccion;
  final String? referencia;
  final int campusCercano;
  final int categoria;
  final bool estaAbierto;
  final double latitud;
  final double longitud;
  final String? telefonoContacto;
  final String? whatsApp;
  final String? horarioApertura;
  final String? logoUrl;
  final String? portadaUrl;
  final double calificacionPromedio;
  final int totalResenas;

  // Calculado en tiempo de ejecución según la ubicación del usuario
  double? distanciaEnMetros;

  LocalModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    this.referencia,
    required this.campusCercano,
    required this.categoria,
    required this.estaAbierto,
    required this.latitud,
    required this.longitud,
    this.telefonoContacto,
    this.whatsApp,
    this.horarioApertura,
    this.logoUrl,
    this.portadaUrl,
    this.calificacionPromedio = 0.0,
    this.totalResenas = 0,
    this.distanciaEnMetros,
  });

  factory LocalModel.fromJson(Map<String, dynamic> json) {
    return LocalModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      referencia: json['referencia']?.toString(),
      campusCercano: (json['campusCercano'] as num?)?.toInt() ?? 1,
      categoria: (json['categoria'] as num?)?.toInt() ?? 99,
      estaAbierto: json['estaAbierto'] == true,
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      telefonoContacto: json['telefonoContacto']?.toString(),
      whatsApp: json['whatsApp']?.toString(),
      horarioApertura: json['horarioApertura']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      portadaUrl: json['portadaUrl']?.toString(),
      calificacionPromedio: (json['calificacionPromedio'] as num?)?.toDouble() ?? 0.0,
      totalResenas: (json['totalResenas'] as num?)?.toInt() ?? 0,
    );
  }

  String get campusNombre => AppConstants.campusNames[campusCercano] ?? 'Campus UTA';
  String get categoriaNombre => AppConstants.categoriasLocal[categoria] ?? 'Comida';
  String get categoriaIcono => AppConstants.categoriaIconos[categoria] ?? '🍽️';

  String get fullLogoUrl => ApiConfig.getMediaUrl(logoUrl);
  String get fullPortadaUrl => ApiConfig.getMediaUrl(portadaUrl);

  String get formattedDistance {
    if (distanciaEnMetros == null) return '';
    return LocationService.formatDistance(distanciaEnMetros!);
  }

  String get formattedWalkingTime {
    if (distanciaEnMetros == null) return '';
    return LocationService.estimateWalkingTime(distanciaEnMetros!);
  }

  void updateDistance(double userLat, double userLng) {
    distanciaEnMetros = LocationService.calculateDistanceMeters(
      startLatitude: userLat,
      startLongitude: userLng,
      endLatitude: latitud,
      endLongitude: longitud,
    );
  }
}

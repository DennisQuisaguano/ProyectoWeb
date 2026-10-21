import '../../core/constants/api_config.dart';
import '../../core/constants/app_constants.dart';

class PlatoModel {
  final String id;
  final String localId;
  final String? localNombre;
  final int? campusCercano;
  final String nombre;
  final String descripcion;
  final String categoriaNombre;
  final int categoria;
  final double precio;
  final String? imagenUrl;
  final bool estaDisponible;
  final bool esPlatoDelDia;
  final int ordenVisualizacion;

  PlatoModel({
    required this.id,
    required this.localId,
    this.localNombre,
    this.campusCercano,
    required this.nombre,
    required this.descripcion,
    required this.categoriaNombre,
    required this.categoria,
    required this.precio,
    this.imagenUrl,
    required this.estaDisponible,
    required this.esPlatoDelDia,
    this.ordenVisualizacion = 0,
  });

  factory PlatoModel.fromJson(Map<String, dynamic> json) {
    return PlatoModel(
      id: json['id']?.toString() ?? '',
      localId: json['localId']?.toString() ?? '',
      localNombre: json['localNombre']?.toString(),
      campusCercano: (json['campusCercano'] as num?)?.toInt(),
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      categoriaNombre: json['categoriaNombre']?.toString() ?? '',
      categoria: (json['categoria'] as num?)?.toInt() ?? 1,
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      imagenUrl: json['imagenUrl']?.toString(),
      estaDisponible: json['estaDisponible'] == true,
      esPlatoDelDia: json['esPlatoDelDia'] == true,
      ordenVisualizacion: (json['ordenVisualizacion'] as num?)?.toInt() ?? 0,
    );
  }

  String get fullImagenUrl => ApiConfig.getMediaUrl(imagenUrl);
  String get formattedPrecio => '\$${precio.toStringAsFixed(2)}';
  String get campusNombre => campusCercano != null ? (AppConstants.campusNames[campusCercano] ?? '') : '';
}

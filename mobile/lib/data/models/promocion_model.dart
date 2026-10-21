import '../../core/constants/api_config.dart';
import '../../core/constants/app_constants.dart';

class PromocionModel {
  final String id;
  final String localId;
  final String? localNombre;
  final String? localLogoUrl;
  final int? campusCercano;
  final String? platoId;
  final String? platoNombre;
  final String titulo;
  final String descripcion;
  final double? precioOriginal;
  final double precioPromocional;
  final String? imagenUrl;
  final String? diasValidos;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool estaActiva;

  PromocionModel({
    required this.id,
    required this.localId,
    this.localNombre,
    this.localLogoUrl,
    this.campusCercano,
    this.platoId,
    this.platoNombre,
    required this.titulo,
    required this.descripcion,
    this.precioOriginal,
    required this.precioPromocional,
    this.imagenUrl,
    this.diasValidos,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estaActiva,
  });

  factory PromocionModel.fromJson(Map<String, dynamic> json) {
    return PromocionModel(
      id: json['id']?.toString() ?? '',
      localId: json['localId']?.toString() ?? '',
      localNombre: json['localNombre']?.toString(),
      localLogoUrl: json['localLogoUrl']?.toString(),
      campusCercano: (json['campusCercano'] as num?)?.toInt(),
      platoId: json['platoId']?.toString(),
      platoNombre: json['platoNombre']?.toString(),
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      precioOriginal: (json['precioOriginal'] as num?)?.toDouble(),
      precioPromocional: (json['precioPromocional'] as num?)?.toDouble() ?? 0.0,
      imagenUrl: json['imagenUrl']?.toString(),
      diasValidos: json['diasValidos']?.toString(),
      fechaInicio: DateTime.tryParse(json['fechaInicio']?.toString() ?? '') ?? DateTime.now(),
      fechaFin: DateTime.tryParse(json['fechaFin']?.toString() ?? '') ?? DateTime.now(),
      estaActiva: json['estaActiva'] == true,
    );
  }

  String get fullImagenUrl => ApiConfig.getMediaUrl(imagenUrl);
  String get fullLocalLogoUrl => ApiConfig.getMediaUrl(localLogoUrl);
  String get formattedPrecioPromocional => '\$${precioPromocional.toStringAsFixed(2)}';
  String? get formattedPrecioOriginal =>
      precioOriginal != null ? '\$${precioOriginal!.toStringAsFixed(2)}' : null;
  String get campusNombre => campusCercano != null ? (AppConstants.campusNames[campusCercano] ?? '') : '';

  int get porcentajeDescuento {
    if (precioOriginal == null || precioOriginal! <= precioPromocional || precioOriginal! <= 0) {
      return 0;
    }
    return (((precioOriginal! - precioPromocional) / precioOriginal!) * 100).round();
  }
}

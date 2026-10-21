import 'package:intl/intl.dart';

class NotificacionModel {
  final String id;
  final String usuarioId;
  final String titulo;
  final String mensaje;
  final String? tipo;
  final bool leida;
  final DateTime createdAt;

  NotificacionModel({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.mensaje,
    this.tipo,
    required this.leida,
    required this.createdAt,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id: json['id']?.toString() ?? '',
      usuarioId: json['usuarioId']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      mensaje: json['mensaje']?.toString() ?? '',
      tipo: json['tipo']?.toString(),
      leida: json['leida'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get formattedFecha {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return DateFormat('dd/MM/yyyy').format(createdAt);
    }
  }
}

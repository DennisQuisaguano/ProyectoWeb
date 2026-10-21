import 'package:intl/intl.dart';

class ResenaModel {
  final String id;
  final String localId;
  final String localNombre;
  final String estudianteId;
  final String estudianteNombre;
  final String? estudianteEmail;
  final int calificacion;
  final String? comentario;
  final DateTime fecha;

  ResenaModel({
    required this.id,
    required this.localId,
    required this.localNombre,
    required this.estudianteId,
    required this.estudianteNombre,
    this.estudianteEmail,
    required this.calificacion,
    this.comentario,
    required this.fecha,
  });

  factory ResenaModel.fromJson(Map<String, dynamic> json) {
    return ResenaModel(
      id: json['id']?.toString() ?? '',
      localId: json['localId']?.toString() ?? '',
      localNombre: json['localNombre']?.toString() ?? '',
      estudianteId: json['estudianteId']?.toString() ?? '',
      estudianteNombre: json['estudianteNombre']?.toString() ?? 'Estudiante UTA',
      estudianteEmail: json['estudianteEmail']?.toString(),
      calificacion: (json['calificacion'] as num?)?.toInt() ?? 5,
      comentario: json['comentario']?.toString(),
      fecha: DateTime.tryParse(json['fecha']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get formattedFecha {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }
}

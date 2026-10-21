class UserModel {
  final String usuarioId;
  final String nombreCompleto;
  final String email;
  final String rol;
  final String token;

  UserModel({
    required this.usuarioId,
    required this.nombreCompleto,
    required this.email,
    required this.rol,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      usuarioId: json['usuarioId']?.toString() ?? '',
      nombreCompleto: json['nombreCompleto']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      rol: json['rol']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'rol': rol,
      'token': token,
    };
  }

  bool get isStudent => rol.toLowerCase() == 'estudiante';
}

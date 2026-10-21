// ignore_for_file: use_super_parameters

class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String message = 'No pudimos conectarnos al servidor. Verifica tu conexión a Internet e intenta nuevamente.'])
      : super(message);
}

class ServerException extends AppException {
  ServerException([String message = 'Ocurrió un problema en el servidor. Por favor intenta de nuevo más tarde.', int? statusCode])
      : super(message, statusCode: statusCode);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Tu sesión ha expirado o necesitas iniciar sesión para realizar esta acción.'])
      : super(message, statusCode: 401);
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, statusCode: 400);
}

class LocationException extends AppException {
  LocationException(String message) : super(message);
}

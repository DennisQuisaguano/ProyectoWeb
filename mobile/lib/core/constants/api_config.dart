class ApiConfig {
  static const String host = '192.168.1.190:5050';

  /// URL Base de la API REST
  static const String baseUrl = 'http://$host/api';

  /// URL Base para recursos estáticos (imágenes de platos, logos, banners)
  static const String baseMediaUrl = 'http://$host';

  /// Resuelve la URL completa de una imagen almacenada en wwwroot
  static String getMediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseMediaUrl/$cleanPath';
  }
}

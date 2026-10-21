import '../../core/network/api_client.dart';
import '../models/notificacion_model.dart';

class NotificacionRemoteDataSource {
  final ApiClient _apiClient;

  NotificacionRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<NotificacionModel>> getUnread() async {
    final response = await _apiClient.get(
      'notificaciones',
      requiresAuth: true,
    );

    if (response is List) {
      return response.map((item) => NotificacionModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> markAsRead() async {
    await _apiClient.post(
      'notificaciones/marcar-leidas',
      requiresAuth: true,
    );
  }

  Future<void> registrarDispositivo(String token, String plataforma) async {
    await _apiClient.post(
      'notificaciones/registrar-dispositivo',
      body: {
        'token': token,
        'plataforma': plataforma,
      },
      requiresAuth: false,
    );
  }

  Future<List<NotificacionModel>> getPublicasRecientes({DateTime? desde}) async {
    final params = desde != null ? {'desde': desde.toIso8601String()} : null;
    final response = await _apiClient.get(
      'notificaciones/publicas-recientes',
      queryParameters: params,
      requiresAuth: false,
    );

    if (response is List) {
      return response.map((item) => NotificacionModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}


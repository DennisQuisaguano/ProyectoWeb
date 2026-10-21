import '../../core/network/api_client.dart';
import '../../core/services/storage_service.dart';

class EstadisticasRemoteDataSource {
  final ApiClient _apiClient;

  EstadisticasRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<void> registrarEvento({
    required String localId,
    required int tipoEvento,
    String? detalle,
  }) async {
    try {
      final user = await StorageService.getUser();
      final estudianteId = user?['usuarioId'];

      await _apiClient.post(
        'estadisticas/evento',
        body: {
          'localId': localId,
          'tipoEvento': tipoEvento,
          'estudianteId': estudianteId,
          'detalle': detalle,
        },
      );
    } catch (_) {
      // Los eventos de estadísticas no deben interrumpir la experiencia de navegación
    }
  }
}

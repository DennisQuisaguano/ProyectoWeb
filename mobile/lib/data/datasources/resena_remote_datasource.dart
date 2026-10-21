import '../../core/network/api_client.dart';
import '../models/resena_model.dart';

class ResenaRemoteDataSource {
  final ApiClient _apiClient;

  ResenaRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<ResenaModel>> getResenasByLocal(String localId) async {
    final response = await _apiClient.get('locales/$localId/resenas');

    if (response is List) {
      return response.map((item) => ResenaModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<ResenaModel> createResena({
    required String localId,
    required int calificacion,
    String? comentario,
  }) async {
    final response = await _apiClient.post(
      'locales/$localId/resenas',
      requiresAuth: true,
      body: {
        'calificacion': calificacion,
        'comentario': comentario?.trim(),
      },
    );

    return ResenaModel.fromJson(response as Map<String, dynamic>);
  }
}

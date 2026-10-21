import '../../core/network/api_client.dart';
import '../models/local_model.dart';

class LocalRemoteDataSource {
  final ApiClient _apiClient;

  LocalRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<LocalModel>> getLocales({
    int? campus,
    int? categoria,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (campus != null) queryParams['campus'] = campus;
    if (categoria != null) queryParams['categoria'] = categoria;
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();

    final response = await _apiClient.get(
      'locales',
      queryParameters: queryParams,
    );

    if (response is List) {
      return response.map((item) => LocalModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<LocalModel> getLocalById(String id) async {
    final response = await _apiClient.get('locales/$id');
    return LocalModel.fromJson(response as Map<String, dynamic>);
  }
}

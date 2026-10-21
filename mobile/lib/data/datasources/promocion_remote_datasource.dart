import '../../core/network/api_client.dart';
import '../models/promocion_model.dart';

class PromocionRemoteDataSource {
  final ApiClient _apiClient;

  PromocionRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<PromocionModel>> getPromocionesGlobales({
    int? campus,
    bool soloActivas = true,
  }) async {
    final queryParams = <String, dynamic>{
      'soloActivas': soloActivas,
    };
    if (campus != null) queryParams['campus'] = campus;

    final response = await _apiClient.get(
      'promociones',
      queryParameters: queryParams,
    );

    if (response is List) {
      return response.map((item) => PromocionModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<PromocionModel>> getPromocionesByLocal(
    String localId, {
    bool? soloActivas,
  }) async {
    final queryParams = <String, dynamic>{};
    if (soloActivas != null) queryParams['soloActivas'] = soloActivas;

    final response = await _apiClient.get(
      'promociones/local/$localId',
      queryParameters: queryParams,
    );

    if (response is List) {
      return response.map((item) => PromocionModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}

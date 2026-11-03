import '../../core/network/api_client.dart';
import '../models/plato_model.dart';

class MenuRemoteDataSource {
  final ApiClient _apiClient;

  MenuRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<PlatoModel>> getPlatosByLocal(
    String localId, {
    bool? soloDisponibles,
    int? categoria,
  }) async {
    final queryParams = <String, dynamic>{};
    if (soloDisponibles != null) queryParams['soloDisponibles'] = soloDisponibles;
    if (categoria != null) queryParams['categoria'] = categoria;

    final response = await _apiClient.get(
      'platos/local/$localId',
      queryParameters: queryParams,
    );

    if (response is List) {
      return response.map((item) => PlatoModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<PlatoModel>> searchPlatos({
    String? search,
    int? campus,
    int? categoria,
    bool? soloDisponibles = true,
    double? precioMaximo,
    bool? soloPlatoDelDia,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();
    if (campus != null) queryParams['campus'] = campus;
    if (categoria != null) queryParams['categoria'] = categoria;
    if (soloDisponibles != null) queryParams['soloDisponibles'] = soloDisponibles;
    if (precioMaximo != null) queryParams['precioMaximo'] = precioMaximo;
    if (soloPlatoDelDia == true) queryParams['soloPlatoDelDia'] = true;

    final response = await _apiClient.get(
      'platos',
      queryParameters: queryParams,
    );

    if (response is List) {
      return response.map((item) => PlatoModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}

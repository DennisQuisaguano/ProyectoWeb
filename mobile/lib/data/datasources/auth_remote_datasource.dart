import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<UserModel> login({required String email, required String password}) async {
    final response = await _apiClient.post(
      'auth/login',
      body: {
        'email': email.trim(),
        'password': password,
      },
    );

    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String nombreCompleto,
    required String email,
    required String password,
    String? telefono,
  }) async {
    final response = await _apiClient.post(
      'auth/register',
      body: {
        'nombreCompleto': nombreCompleto.trim(),
        'email': email.trim(),
        'password': password,
        'telefono': telefono?.trim(),
        'rol': 3, // RolUsuario.Estudiante = 3
      },
    );

    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _apiClient.get(
      'auth/me',
      requiresAuth: true,
    );
    return response as Map<String, dynamic>;
  }
}

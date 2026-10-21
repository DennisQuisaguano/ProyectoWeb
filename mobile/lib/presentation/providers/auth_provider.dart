import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/services/storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRemoteDataSource _dataSource;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? AuthRemoteDataSource();

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> checkSession() async {
    final token = await StorageService.getToken();
    final userJson = await StorageService.getUser();

    if (token != null && userJson != null) {
      _currentUser = UserModel.fromJson(userJson);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _dataSource.login(email: email, password: password);
      _currentUser = user;
      await StorageService.saveToken(user.token);
      await StorageService.saveUser(user.toJson());
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado al iniciar sesión.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String nombreCompleto,
    required String email,
    required String password,
    String? telefono,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _dataSource.register(
        nombreCompleto: nombreCompleto,
        email: email,
        password: password,
        telefono: telefono,
      );
      _currentUser = user;
      await StorageService.saveToken(user.token);
      await StorageService.saveUser(user.toJson());
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado al registrarte.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await StorageService.clearSession();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/estadisticas_remote_datasource.dart';
import '../../data/datasources/promocion_remote_datasource.dart';
import '../../data/models/promocion_model.dart';

class PromocionProvider with ChangeNotifier {
  final PromocionRemoteDataSource _dataSource;
  final EstadisticasRemoteDataSource _estadisticasDataSource;

  List<PromocionModel> _globalPromotions = [];
  List<PromocionModel> _localPromotions = [];
  bool _isLoading = false;
  String? _errorMessage;

  PromocionProvider({
    PromocionRemoteDataSource? dataSource,
    EstadisticasRemoteDataSource? estadisticasDataSource,
  })  : _dataSource = dataSource ?? PromocionRemoteDataSource(),
        _estadisticasDataSource = estadisticasDataSource ?? EstadisticasRemoteDataSource();

  List<PromocionModel> get globalPromotions => _globalPromotions;
  List<PromocionModel> get localPromotions => _localPromotions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchGlobalPromotions({int? campus}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _globalPromotions = await _dataSource.getPromocionesGlobales(
        campus: campus,
        soloActivas: true,
      );
      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'No se pudieron cargar las promociones activas.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPromotionsByLocal(String localId) async {
    try {
      _localPromotions = await _dataSource.getPromocionesByLocal(
        localId,
        soloActivas: true,
      );
      notifyListeners();
    } catch (_) {
      _localPromotions = [];
      notifyListeners();
    }
  }

  void registrarClickPromocion(String localId, String promocionTitulo) {
    _estadisticasDataSource.registrarEvento(
      localId: localId,
      tipoEvento: 3, // ClicPromocion
      detalle: 'Clic en promoción: $promocionTitulo',
    );
  }
}

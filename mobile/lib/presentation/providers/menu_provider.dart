import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/menu_remote_datasource.dart';
import '../../data/models/plato_model.dart';

class MenuProvider with ChangeNotifier {
  final MenuRemoteDataSource _dataSource;

  List<PlatoModel> _localDishes = [];
  List<PlatoModel> _searchResults = [];
  List<PlatoModel> _platosDelDiaGlobal = [];
  int? _lastPlatosDelDiaCampus;
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;

  MenuProvider({MenuRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? MenuRemoteDataSource();

  List<PlatoModel> get localDishes => _localDishes;
  List<PlatoModel> get searchResults => _searchResults;

  /// Platos del día de todos los locales aprobados (inicio).
  List<PlatoModel> get platosDelDiaGlobal => _platosDelDiaGlobal;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  // Platos del día del local seleccionado
  List<PlatoModel> get platosDelDia =>
      _localDishes.where((p) => p.esPlatoDelDia && p.estaDisponible).toList();

  Future<void> fetchDishesByLocal(String localId, {int? categoria}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _localDishes = await _dataSource.getPlatosByLocal(
        localId,
        categoria: categoria,
        soloDisponibles: true,
      );
      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'No se pudo cargar el menú del local.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchDishes({
    String? query,
    int? campus,
    int? categoria,
    double? precioMaximo,
    bool soloPlatoDelDia = false,
  }) async {
    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _dataSource.searchPlatos(
        search: query,
        campus: campus,
        categoria: categoria,
        precioMaximo: precioMaximo,
        soloDisponibles: true,
        soloPlatoDelDia: soloPlatoDelDia,
      );
      _isSearching = false;
      notifyListeners();
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isSearching = false;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Error al realizar la búsqueda de platos.';
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Carga los platos del día de todos los locales (opcionalmente por campus).
  /// No muestra estado de carga: se actualiza en silencio para evitar parpadeos.
  Future<void> fetchPlatosDelDia({int? campus}) async {
    _lastPlatosDelDiaCampus = campus;
    try {
      _platosDelDiaGlobal = await _dataSource.searchPlatos(
        campus: campus,
        soloDisponibles: true,
        soloPlatoDelDia: true,
      ).then((lista) => lista.where((p) => p.esPlatoDelDia).toList());
      notifyListeners();
    } catch (_) {
      // Se conserva la lista anterior si falla la actualización.
    }
  }

  Future<void> refreshPlatosDelDia() => fetchPlatosDelDia(campus: _lastPlatosDelDiaCampus);

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}

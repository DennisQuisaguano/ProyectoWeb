import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/menu_remote_datasource.dart';
import '../../data/models/plato_model.dart';

class MenuProvider with ChangeNotifier {
  final MenuRemoteDataSource _dataSource;

  List<PlatoModel> _localDishes = [];
  List<PlatoModel> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;

  MenuProvider({MenuRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? MenuRemoteDataSource();

  List<PlatoModel> get localDishes => _localDishes;
  List<PlatoModel> get searchResults => _searchResults;
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

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}

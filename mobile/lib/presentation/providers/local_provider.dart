import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/services/storage_service.dart';
import '../../data/datasources/estadisticas_remote_datasource.dart';
import '../../data/datasources/local_remote_datasource.dart';
import '../../data/datasources/resena_remote_datasource.dart';
import '../../data/models/local_model.dart';
import '../../data/models/resena_model.dart';

/// Orden de la lista de locales en Inicio.
enum LocalSortOrder { cercanos, mejorValorados }

class LocalProvider with ChangeNotifier {
  final LocalRemoteDataSource _localDataSource;
  final ResenaRemoteDataSource _resenaDataSource;
  final EstadisticasRemoteDataSource _estadisticasDataSource;

  List<LocalModel> _locales = [];
  LocalModel? _selectedLocal;
  List<ResenaModel> _selectedLocalResenas = [];
  List<String> _favoriteIds = [];

  bool _isLoading = false;
  bool _isLoadingDetail = false;
  bool _isLoadingResenas = false;
  bool _isSubmittingResena = false;
  String? _errorMessage;

  // Filtros aplicados
  int? _filterCampus;
  int? _filterCategoria;
  double? _filterMaxDistanciaMeters;
  bool _filterSoloAbiertos = false;
  double? _filterPresupuestoMax; // ej. 3.0 para "< $3"
  bool _filterSoloComidaRapida = false;
  String _searchQuery = '';

  LocalProvider({
    LocalRemoteDataSource? localDataSource,
    ResenaRemoteDataSource? resenaDataSource,
    EstadisticasRemoteDataSource? estadisticasDataSource,
  })  : _localDataSource = localDataSource ?? LocalRemoteDataSource(),
        _resenaDataSource = resenaDataSource ?? ResenaRemoteDataSource(),
        _estadisticasDataSource = estadisticasDataSource ?? EstadisticasRemoteDataSource();

  List<LocalModel> get locales => _locales;
  LocalModel? get selectedLocal => _selectedLocal;
  List<ResenaModel> get selectedLocalResenas => _selectedLocalResenas;
  List<String> get favoriteIds => _favoriteIds;

  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isLoadingResenas => _isLoadingResenas;
  bool get isSubmittingResena => _isSubmittingResena;
  String? get errorMessage => _errorMessage;

  // Getters de filtros
  int? get filterCampus => _filterCampus;
  int? get filterCategoria => _filterCategoria;
  double? get filterMaxDistanciaMeters => _filterMaxDistanciaMeters;
  bool get filterSoloAbiertos => _filterSoloAbiertos;
  double? get filterPresupuestoMax => _filterPresupuestoMax;
  bool get filterSoloComidaRapida => _filterSoloComidaRapida;

  LocalSortOrder _sortOrder = LocalSortOrder.cercanos;
  LocalSortOrder get sortOrder => _sortOrder;

  void setSortOrder(LocalSortOrder order) {
    if (_sortOrder == order) return;
    _sortOrder = order;
    notifyListeners();
  }

  /// Retorna los locales filtrados en memoria de manera reactiva e instantánea
  List<LocalModel> get filteredLocales {
    return _locales.where((local) {
      if (_filterCampus != null && local.campusCercano != _filterCampus) {
        return false;
      }
      if (_filterCategoria != null && local.categoria != _filterCategoria) {
        return false;
      }
      if (_filterSoloAbiertos && !local.estaAbierto) {
        return false;
      }
      if (_filterSoloComidaRapida && local.categoria != 2) {
        return false;
      }
      if (_filterMaxDistanciaMeters != null &&
          local.distanciaEnMetros != null &&
          local.distanciaEnMetros! > _filterMaxDistanciaMeters!) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchNombre = local.nombre.toLowerCase().contains(query);
        final matchDesc = local.descripcion.toLowerCase().contains(query);
        final matchDir = local.direccion.toLowerCase().contains(query);
        if (!matchNombre && !matchDesc && !matchDir) return false;
      }
      return true;
    }).toList()
      ..sort(_compareBySortOrder);
  }

  int _compareBySortOrder(LocalModel a, LocalModel b) {
    if (_sortOrder == LocalSortOrder.mejorValorados) {
      if (a.estaAbierto != b.estaAbierto) return a.estaAbierto ? -1 : 1;
      return b.calificacionPromedio.compareTo(a.calificacionPromedio);
    }
    // Más cercanos: los que no tienen distancia calculada quedan al final.
    final da = a.distanciaEnMetros;
    final db = b.distanciaEnMetros;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  }

  /// Locales recomendados (ordenados por mejor calificación y abiertos)
  List<LocalModel> get recommendedLocales {
    final list = List<LocalModel>.from(_locales);
    list.sort((a, b) {
      if (a.estaAbierto != b.estaAbierto) {
        return a.estaAbierto ? -1 : 1;
      }
      return b.calificacionPromedio.compareTo(a.calificacionPromedio);
    });
    return list.take(6).toList();
  }

  /// Locales cercanos (ordenados por distancia calculada)
  List<LocalModel> get nearbyLocales {
    final list = _locales.where((l) => l.distanciaEnMetros != null).toList();
    list.sort((a, b) => a.distanciaEnMetros!.compareTo(b.distanciaEnMetros!));
    return list;
  }

  Future<void> initFavorites() async {
    _favoriteIds = await StorageService.getFavoriteLocalIds();
    notifyListeners();
  }

  Future<bool> toggleFavorite(String localId) async {
    final isFav = await StorageService.toggleFavoriteLocal(localId);
    _favoriteIds = await StorageService.getFavoriteLocalIds();
    notifyListeners();
    if (isFav) {
      _estadisticasDataSource.registrarEvento(
        localId: localId,
        tipoEvento: 2, // MenuGuardado / Favorito
      );
    }
    return isFav;
  }

  Future<void> fetchLocales({
    int? campus,
    int? categoria,
    String? search,
    double? userLat,
    double? userLng,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _localDataSource.getLocales(
        campus: campus,
        categoria: categoria,
        search: search,
      );

      // Calcular distancia si tenemos coordenadas
      if (userLat != null && userLng != null) {
        for (final l in list) {
          l.updateDistance(userLat, userLng);
        }
      }

      _locales = list;
      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'No se pudieron cargar los locales. Intenta nuevamente.';
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateDistances(double userLat, double userLng) {
    for (final l in _locales) {
      l.updateDistance(userLat, userLng);
    }
    notifyListeners();
  }

  Future<void> fetchLocalDetail(String id, {double? userLat, double? userLng}) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final local = await _localDataSource.getLocalById(id);
      if (userLat != null && userLng != null) {
        local.updateDistance(userLat, userLng);
      }
      _selectedLocal = local;
      _isLoadingDetail = false;
      notifyListeners();

      // Registrar estadística de visita
      _estadisticasDataSource.registrarEvento(
        localId: id,
        tipoEvento: 1, // VisitaPerfil
      );

      // Cargar reseñas en segundo plano
      fetchResenas(id);
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar el detalle del local.';
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> fetchResenas(String localId) async {
    _isLoadingResenas = true;
    notifyListeners();

    try {
      _selectedLocalResenas = await _resenaDataSource.getResenasByLocal(localId);
      _isLoadingResenas = false;
      notifyListeners();
    } catch (_) {
      _isLoadingResenas = false;
      notifyListeners();
    }
  }

  Future<bool> addResena({
    required String localId,
    required int calificacion,
    String? comentario,
  }) async {
    _isSubmittingResena = true;
    notifyListeners();

    try {
      final newResena = await _resenaDataSource.createResena(
        localId: localId,
        calificacion: calificacion,
        comentario: comentario,
      );

      _selectedLocalResenas.insert(0, newResena);
      _isSubmittingResena = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _isSubmittingResena = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _isSubmittingResena = false;
      _errorMessage = 'Error al publicar la reseña.';
      notifyListeners();
      return false;
    }
  }

  void registrarContacto(String localId, {bool isWhatsApp = true}) {
    _estadisticasDataSource.registrarEvento(
      localId: localId,
      tipoEvento: isWhatsApp ? 4 : 1, // ClicContactoWhatsApp
      detalle: isWhatsApp ? 'Contacto vía WhatsApp' : 'Llamada telefónica',
    );
  }

  void registrarComoLlegar(String localId) {
    _estadisticasDataSource.registrarEvento(
      localId: localId,
      tipoEvento: 5, // ClicComoLlegar
    );
  }

  // Métodos de filtros
  void setFilterCampus(int? campus) {
    _filterCampus = campus;
    notifyListeners();
  }

  void setFilterCategoria(int? categoria) {
    _filterCategoria = categoria;
    notifyListeners();
  }

  void setFilterMaxDistancia(double? meters) {
    _filterMaxDistanciaMeters = meters;
    notifyListeners();
  }

  void setFilterSoloAbiertos(bool val) {
    _filterSoloAbiertos = val;
    notifyListeners();
  }

  void setFilterPresupuesto(double? maxPrice) {
    _filterPresupuestoMax = maxPrice;
    notifyListeners();
  }

  void setFilterSoloComidaRapida(bool val) {
    _filterSoloComidaRapida = val;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetFilters() {
    _filterCampus = null;
    _filterCategoria = null;
    _filterMaxDistanciaMeters = null;
    _filterSoloAbiertos = false;
    _filterPresupuestoMax = null;
    _filterSoloComidaRapida = false;
    _searchQuery = '';
    notifyListeners();
  }
}

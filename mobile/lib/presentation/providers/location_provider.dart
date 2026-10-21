import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/location_service.dart';
import '../../core/services/storage_service.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  bool _permissionDenied = false;
  int _selectedCampusId = 1; // Default Campus Huachi

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  bool get permissionDenied => _permissionDenied;
  int get selectedCampusId => _selectedCampusId;

  String get campusNombre => AppConstants.campusNames[_selectedCampusId] ?? 'Campus UTA';

  double get referenceLatitude {
    if (_currentPosition != null) return _currentPosition!.latitude;
    switch (_selectedCampusId) {
      case 2:
        return AppConstants.utaIngahurcoLat;
      case 3:
        return AppConstants.utaQuerochacaLat;
      case 1:
      default:
        return AppConstants.utaHuachiLat;
    }
  }

  double get referenceLongitude {
    if (_currentPosition != null) return _currentPosition!.longitude;
    switch (_selectedCampusId) {
      case 2:
        return AppConstants.utaIngahurcoLng;
      case 3:
        return AppConstants.utaQuerochacaLng;
      case 1:
      default:
        return AppConstants.utaHuachiLng;
    }
  }

  Future<void> initLocation({bool waitForGps = false}) async {
    _selectedCampusId = await StorageService.getSelectedCampus();
    notifyListeners();
    if (waitForGps) {
      await fetchUserLocation();
    } else {
      // Disparar obtención de GPS en segundo plano sin bloquear la UI ni llamadas a la API
      fetchUserLocation();
    }
  }

  Future<Position?> fetchUserLocation() async {
    _isLoading = true;
    notifyListeners();

    final pos = await LocationService.getCurrentPosition();
    if (pos != null) {
      _currentPosition = pos;
      _permissionDenied = false;
    } else {
      _permissionDenied = true;
    }

    _isLoading = false;
    notifyListeners();
    return pos;
  }

  Future<void> setCampus(int campusId) async {
    _selectedCampusId = campusId;
    await StorageService.saveSelectedCampus(campusId);
    notifyListeners();
  }
}

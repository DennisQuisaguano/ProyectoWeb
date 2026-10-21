import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/services/notification_service.dart';
import '../../data/datasources/notificacion_remote_datasource.dart';
import '../../data/models/notificacion_model.dart';

class NotificacionProvider with ChangeNotifier {
  final NotificacionRemoteDataSource _dataSource;

  List<NotificacionModel> _notificaciones = [];
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _pollingTimer;
  final Set<String> _notifiedIds = {};
  DateTime _lastCheckTime = DateTime.now().toUtc().subtract(const Duration(hours: 1));

  NotificacionProvider({NotificacionRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? NotificacionRemoteDataSource() {
    startRealtimePolling();
  }

  List<NotificacionModel> get notificaciones => _notificaciones;
  int get unreadCount => _notificaciones.where((n) => !n.leida).length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Inicia polling periódico cada 5 segundos para recibir notificaciones del backend en tiempo real
  void startRealtimePolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      checkNewPromotionsAndNotify();
    });
  }

  /// Consulta ofertas nuevas/actualizadas y emite notificación a la barra de estado de Android
  Future<void> checkNewPromotionsAndNotify() async {
    try {
      final recientes = await _dataSource.getPublicasRecientes(desde: _lastCheckTime);
      for (final notif in recientes) {
        if (!_notifiedIds.contains(notif.id)) {
          _notifiedIds.add(notif.id);

          // Disparar notificación emergente nativa en la barra de Android
          await NotificationService.showNotification(
            id: notif.id.hashCode,
            title: notif.tipo == 'promocion'
                ? '🔥 ¡Nueva Oferta Universitaria UTA!'
                : '📣 Aviso Gastronómico UTA',
            body: notif.mensaje,
          );

          // Agregar al listado en memoria si no estaba
          if (!_notificaciones.any((n) => n.id == notif.id)) {
            _notificaciones.insert(0, notif);
            notifyListeners();
          }
        }
      }
      _lastCheckTime = DateTime.now().toUtc().subtract(const Duration(minutes: 1));
    } catch (_) {
      // Evitar spam de errores en el ciclo periódico
    }
  }

  Future<void> fetchNotificaciones() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notificaciones = await _dataSource.getUnread();
      for (final n in _notificaciones) {
        _notifiedIds.add(n.id);
      }
      _isLoading = false;
      notifyListeners();
    } on UnauthorizedException {
      // Si el estudiante no está autenticado, obtenemos las públicas recientes
      try {
        _notificaciones = await _dataSource.getPublicasRecientes();
        for (final n in _notificaciones) {
          _notifiedIds.add(n.id);
        }
      } catch (_) {}
      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dataSource.markAsRead();
      _notificaciones.clear();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> registrarDispositivoToken(String token, String plataforma) async {
    try {
      await _dataSource.registrarDispositivo(token, plataforma);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}


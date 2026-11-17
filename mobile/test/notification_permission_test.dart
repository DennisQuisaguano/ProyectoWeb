import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uta_gastronomia/core/services/storage_service.dart';
import 'package:uta_gastronomia/presentation/providers/notificacion_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  group('Pruebas de Permisos y Preferencias de Notificaciones', () {
    test('StorageService guarda y recupera la preferencia de notificaciones', () async {
      expect(await StorageService.getNotificationsEnabled(), isTrue);

      await StorageService.setNotificationsEnabled(false);
      expect(await StorageService.getNotificationsEnabled(), isFalse);

      await StorageService.setNotificationsEnabled(true);
      expect(await StorageService.getNotificationsEnabled(), isTrue);
    });

    test('NotificacionProvider inicializa con estado por defecto y verifica preferencia', () async {
      await StorageService.setNotificationsEnabled(false);

      final provider = NotificacionProvider();
      await provider.checkNotificationStatus();

      expect(provider.userNotificationsEnabled, isFalse);
      expect(provider.areNotificationsActive, isFalse);

      provider.dispose();
    });

    test('NotificacionProvider desactiva notificaciones correctamente', () async {
      final provider = NotificacionProvider();

      final result = await provider.setNotificationsEnabled(false);
      expect(result, isTrue);
      expect(provider.userNotificationsEnabled, isFalse);
      expect(provider.areNotificationsActive, isFalse);
      expect(await StorageService.getNotificationsEnabled(), isFalse);

      provider.dispose();
    });
  });
}

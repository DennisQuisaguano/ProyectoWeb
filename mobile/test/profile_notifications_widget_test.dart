import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uta_gastronomia/core/services/storage_service.dart';
import 'package:uta_gastronomia/presentation/providers/auth_provider.dart';
import 'package:uta_gastronomia/presentation/providers/local_provider.dart';
import 'package:uta_gastronomia/presentation/providers/location_provider.dart';
import 'package:uta_gastronomia/presentation/providers/notificacion_provider.dart';
import 'package:uta_gastronomia/presentation/screens/profile/profile_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('ProfileScreen muestra el interruptor de notificaciones y diálogo al estar desactivado', (tester) async {
    final notifProv = NotificacionProvider();
    final authProv = AuthProvider();
    final locProv = LocationProvider();
    final localProv = LocalProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: notifProv),
          ChangeNotifierProvider.value(value: authProv),
          ChangeNotifierProvider.value(value: locProv),
          ChangeNotifierProvider.value(value: localProv),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Comprobar que existe el ListTile de Avisos de Promociones
    expect(find.text('Avisos de Promociones'), findsOneWidget);

    // En test unitario sin Android nativo, los permisos del SO están en false
    expect(find.textContaining('Permisos desactivados en el teléfono'), findsOneWidget);

    // Intentar tocar el ListTile para activar
    await tester.tap(find.text('Avisos de Promociones'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Debe desplegar el AlertDialog informativo con opción de Abrir Ajustes
    expect(find.text('Activar Notificaciones'), findsOneWidget);
    expect(find.text('Abrir Ajustes'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);

    // Cerrar el diálogo
    await tester.tap(find.text('Cancelar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Activar Notificaciones'), findsNothing);

    notifProv.dispose();
  });
}

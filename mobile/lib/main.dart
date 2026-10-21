import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/local_provider.dart';
import 'presentation/providers/location_provider.dart';
import 'presentation/providers/menu_provider.dart';
import 'presentation/providers/notificacion_provider.dart';
import 'presentation/providers/promocion_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => LocalProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => PromocionProvider()),
        ChangeNotifierProvider(create: (_) => NotificacionProvider()),
      ],
      child: const UtaGastronomiaApp(),
    ),
  );
}

class UtaGastronomiaApp extends StatelessWidget {
  const UtaGastronomiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Soporte automático a preferencias del SO
      home: const SplashScreen(),
    );
  }
}

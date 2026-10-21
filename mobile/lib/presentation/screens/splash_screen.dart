import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';
import '../../shared/puni/puni_assets.dart';
import '../../shared/widgets/puni_mascot.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../providers/notificacion_provider.dart';
import 'main_navigation_screen.dart';
import 'onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _zoomController;
  late AnimationController _textController;
  late Animation<double> _zoomAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  double _loadingProgress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Zoom lento de 1.0 a 1.06 (4 s) para la escena vertical de inicio.jpg
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeOutCubic),
    );

    // Fade y Slide escalonado para los textos y ruta de carga
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _textController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );

    _zoomController.forward();
    _textController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheImages();
      _startAppInitialization();
    });
  }

  void _precacheImages() {
    // Precarga de los assets críticos en memoria
    precacheImage(const AssetImage(PuniAssets.splash), context);
    precacheImage(const AssetImage(PuniAssets.waving), context);
    precacheImage(const AssetImage(PuniAssets.discovering), context);
    precacheImage(const AssetImage(PuniAssets.confused), context);
    precacheImage(const AssetImage(PuniAssets.sad), context);
    precacheImage(const AssetImage(PuniAssets.promo), context);
    precacheImage(const AssetImage(PuniAssets.shy), context);
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _startAppInitialization() async {
    setState(() {
      _hasError = false;
      _loadingProgress = 0.15;
    });

    final auth = context.read<AuthProvider>();
    final location = context.read<LocationProvider>();
    final notificaciones = context.read<NotificacionProvider>();

    try {
      // 1. Permisos y Token FCM en segundo plano
      NotificationService.requestPermission().then((_) async {
        try {
          final deviceToken = await NotificationService.getDeviceToken();
          if (auth.isAuthenticated) {
            await notificaciones.registrarDispositivoToken(deviceToken, 'android');
          }
        } catch (_) {}
      });

      _updateProgress(0.35);

      // 2. Tareas en paralelo con límite de timeout de 10 segundos
      final initFuture = Future.wait([
        auth.checkSession().then((_) {
          _updateProgress(0.60);
        }),
        location.initLocation().then((_) {
          _updateProgress(0.85);
        }),
        StorageService.hasSeenOnboarding(),
        Future.delayed(const Duration(milliseconds: 2500)), // Mínimo 2.5 s para gozar la animación
      ]).timeout(const Duration(seconds: 10));

      final results = await initFuture;
      _updateProgress(1.0);

      final bool hasSeenOnboarding = results[2] as bool;

      // Esperar breve rebote final del pin en 100%
      await Future.delayed(const Duration(milliseconds: 350));

      if (mounted) {
        final target = hasSeenOnboarding ? const MainNavigationScreen() : const OnboardingScreen();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => target,
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 450),
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'El servidor tardó demasiado en responder.\nVerifica tu conexión a internet.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'No pudimos conectarnos al sistema gastronómico.\nRevisa tu red o intenta de nuevo.';
        });
      }
    }
  }

  void _updateProgress(double val) {
    if (mounted) {
      setState(() {
        _loadingProgress = val.clamp(0.0, 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: _hasError ? _buildErrorState() : _buildSplashScene(),
    );
  }

  /// Escena principal con inicio.jpg a pantalla completa + degradado + ruta punteada
  Widget _buildSplashScene() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Imagen vertical completa (inicio.jpg) con zoom suave 1.0 -> 1.06
            AnimatedBuilder(
              animation: _zoomAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _zoomAnimation.value,
                  alignment: const Alignment(0.0, -0.2), // Mantiene a Puni perfectamente centrado
                  child: Image.asset(
                    PuniAssets.splash,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.0, -0.2),
                    errorBuilder: (_, __, ___) => Container(color: AppColors.primaryDark),
                  ),
                );
              },
            ),

            // 2. Degradado Azul UTA inferior para garantizar contraste y legibilidad absoluta
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 0.72, 1.0],
                    colors: [
                      Colors.transparent,
                      AppColors.primaryDark.withOpacity(0.15),
                      AppColors.primaryDark.withOpacity(0.82),
                      AppColors.primaryDark.withOpacity(0.98),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Contenido Inferior: Textos, Ruta Punteada Interactiva y Footer
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Título de la Plataforma
                          const Text(
                            'UTA Gastronomía',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 3)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Subtítulo
                          Text(
                            'Encuentra dónde comer cerca de tu campus',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.90),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              shadows: const [
                                Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 4. Ruta punteada horizontal con ícono de pin que avanza al progreso real
                          _buildDottedProgressRoute(),
                          const SizedBox(height: 20),

                          // Footer institucional
                          Text(
                            'Universidad Técnica de Ambato • Campus Universitario',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.68),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Ruta punteada horizontal de 0 a 100 con pin/cubiertos que avanza y rebota
  Widget _buildDottedProgressRoute() {
    const routeWidth = 220.0;
    final clampedProgress = _loadingProgress.clamp(0.0, 1.0);
    final pinOffset = (routeWidth - 28) * clampedProgress;

    return SizedBox(
      width: routeWidth,
      height: 38,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Línea punteada de fondo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              16,
              (index) {
                final isReached = (index / 15.0) <= clampedProgress;
                return Container(
                  width: 5,
                  height: 3,
                  decoration: BoxDecoration(
                    color: isReached ? AppColors.primaryVibrant : Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),

          // Ícono de pin o cubiertos que se desliza por la ruta
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: pinOffset,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: clampedProgress >= 1.0 ? 1.25 : 1.0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primaryVibrant,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryVibrant.withOpacity(0.6),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.place_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de error amigable dentro del Splash con Puni triste (PuniMood.sad)
  Widget _buildErrorState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PuniMascot(
                mood: PuniMood.sad,
                size: 160,
              ),
              const SizedBox(height: 24),
              const Text(
                'No pudimos conectarnos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage.isNotEmpty ? _errorMessage : 'Revisa tu conexión a internet o intenta nuevamente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _startAppInitialization,
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                label: const Text(
                  'Reintentar conexión',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

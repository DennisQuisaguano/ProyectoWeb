import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/puni_mascot.dart';
import '../../widgets/custom_button.dart';
import '../main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingStep> _steps = const [
    _OnboardingStep(
      mood: PuniMood.discovering,
      badge: 'DESCUBRE',
      title: '¿Dónde comer hoy?',
      description: 'Encuentra al instante restaurantes, comedores y cafeterías alrededor de tu campus universitario.',
      highlight: 'Almuerzos desde \$2.50',
    ),
    _OnboardingStep(
      mood: PuniMood.discovering,
      badge: 'MAPA UTA',
      title: 'Explora cerca de ti',
      description: 'Ubica locales en los campus Huachi, Ingahurco o Querochaca con tiempo estimado de caminata.',
      highlight: 'Geolocalización en tiempo real',
    ),
    _OnboardingStep(
      mood: PuniMood.promo,
      badge: 'AHORRA',
      title: 'Compara y aprovecha',
      description: 'Revisa precios de platos, menús estudiantiles y promociones 2x1 exclusivas para la comunidad técnica.',
      highlight: 'Descuentos universitarios',
    ),
    _OnboardingStep(
      mood: PuniMood.waving,
      badge: 'COMUNIDAD',
      title: 'Tu lugar favorito',
      description: 'Califica la sazón, deja tus reseñas y descubre las mejores recomendaciones gastronómicas de la UTA.',
      highlight: 'Reseñas 100% reales',
    ),
  ];

  void _finishOnboarding() async {
    await StorageService.setOnboardingSeen();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainNavigationScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text(
              'Saltar',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Mascota oficial 3D Puni transparente sin tarjetas cuadradas
                        PuniMascot(
                          mood: step.mood,
                          size: 190,
                          shadow: true,
                        ),
                        const SizedBox(height: 32),

                        // Chip de beneficio destacado Soft UI
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primarySubtle,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryLight),
                          ),
                          child: Text(
                            step.highlight,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Título
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Descripción corta
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Controles inferiores: Indicadores y Botón
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
              child: Column(
                children: [
                  // Indicador de Páginas Soft UI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón Continuar / Empezar
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _currentPage == _steps.length - 1 ? '¡Empezar a Explorar!' : 'Continuar',
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final PuniMood mood;
  final String badge;
  final String title;
  final String description;
  final String highlight;

  const _OnboardingStep({
    required this.mood,
    required this.badge,
    required this.title,
    required this.description,
    required this.highlight,
  });
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/puni_mascot.dart';

/// Pantalla o vista de carga moderna y amigable cuando la app consulta
/// locales, menús o inicializa geolocalización.
class LoadingScreenView extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool fullScreen;

  const LoadingScreenView({
    super.key,
    this.title = 'Puni está buscando...',
    this.subtitle = 'Encontrando los mejores locales cerca de tu campus',
    this.fullScreen = false,
  });

  @override
  State<LoadingScreenView> createState() => _LoadingScreenViewState();
}

class _LoadingScreenViewState extends State<LoadingScreenView> {
  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mascota oficial Puni 3D
            const PuniMascot(
              mood: PuniMood.discovering,
              size: 130,
              shadow: true,
            ),
            const SizedBox(height: 24),

            // Título amigable
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Subtítulo
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Barra de progreso Soft UI estilizada
            Container(
              width: 120,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.fullScreen) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: content),
      );
    }

    return content;
  }
}

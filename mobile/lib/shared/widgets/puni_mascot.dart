import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../puni/puni_assets.dart';

enum PuniMood { splash, waving, discovering, confused, sad, promo, shy }

/// Componente visual reutilizable para la mascota oficial Puni de la UTA.
///
/// Renderiza las ilustraciones 3D oficiales directamente sobre el fondo
/// transparente, con animaciones sutiles por mood (Transform y Opacity),
/// sombra elíptica que respira y soporte para `MediaQuery.disableAnimations`.
class PuniMascot extends StatefulWidget {
  final PuniMood mood;
  final double size; // alto máximo
  final bool animated; // default true
  final bool shadow; // default true: sombra elíptica suave bajo los pies
  final VoidCallback? onTap;

  const PuniMascot({
    super.key,
    required this.mood,
    this.size = 140,
    this.animated = true,
    this.shadow = true,
    this.onTap,
  });

  @override
  State<PuniMascot> createState() => _PuniMascotState();
}

class _PuniMascotState extends State<PuniMascot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _getLoopDuration(widget.mood),
    );

    if (widget.animated) {
      _controller.repeat(reverse: true);
    }
  }

  Duration _getLoopDuration(PuniMood mood) {
    return switch (mood) {
      PuniMood.splash || PuniMood.waving => const Duration(milliseconds: 2400),
      PuniMood.discovering => const Duration(milliseconds: 2200),
      PuniMood.confused => const Duration(milliseconds: 2600),
      PuniMood.sad => const Duration(milliseconds: 2800),
      PuniMood.promo => const Duration(milliseconds: 3000),
      PuniMood.shy => const Duration(milliseconds: 2500),
    };
  }

  @override
  void didUpdateWidget(PuniMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      _controller.duration = _getLoopDuration(widget.mood);
      if (widget.animated && !_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getAssetPath(PuniMood mood) {
    return switch (mood) {
      PuniMood.splash => PuniAssets.splash,
      PuniMood.waving => PuniAssets.waving,
      PuniMood.discovering => PuniAssets.discovering,
      PuniMood.confused => PuniAssets.confused,
      PuniMood.sad => PuniAssets.sad,
      PuniMood.promo => PuniAssets.promo,
      PuniMood.shy => PuniAssets.shy,
    };
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations || !widget.animated;
    final assetPath = _getAssetPath(widget.mood);

    // Dimensiones proporcionales
    final width = widget.size * 0.95;
    final height = widget.size;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: RepaintBoundary(
        child: SizedBox(
          width: width,
          height: height + (widget.shadow ? 14 : 0),
          child: disableAnimations
              ? Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (widget.shadow) _buildShadow(1.0),
                    Positioned(
                      bottom: widget.shadow ? 10 : 0,
                      child: _buildImage(assetPath, width, height),
                    ),
                  ],
                )
              : AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = _controller.value;
                    final animData = _calculateMoodTransform(widget.mood, t);

                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Sombra que respira inversamente a la altura de Puni
                        if (widget.shadow)
                          _buildShadow(animData.shadowScale),

                        // Personaje animado
                        Positioned(
                          bottom: (widget.shadow ? 10 : 0) + animData.translateY,
                          child: Transform(
                            alignment: Alignment.bottomCenter,
                            transform: Matrix4.identity()
                              ..scale(animData.scale, animData.scale)
                              ..rotateZ(animData.rotateZ),
                            child: widget.mood == PuniMood.promo
                                ? _buildPromoGleam(assetPath, width, height, t)
                                : _buildImage(assetPath, width, height),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }

  /// Sombra elíptica suave bajo los pies con degradado radial
  Widget _buildShadow(double scale) {
    final shadowWidth = widget.size * 0.55 * scale;
    final shadowHeight = widget.size * 0.12 * scale;

    return Positioned(
      bottom: 0,
      child: Container(
        width: shadowWidth,
        height: shadowHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.elliptical(shadowWidth, shadowHeight)),
          gradient: RadialGradient(
            colors: [
              Colors.black.withOpacity(0.25 * (1.1 - (scale - 1.0))),
              Colors.black.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String assetPath, double w, double h) {
    return Image.asset(
      assetPath,
      width: w,
      height: h,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Placeholder amigable en caso de que un asset falle, NUNCA crash
        return Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryLight, width: 2),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 36),
                SizedBox(height: 4),
                Text(
                  'Puni UTA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Destello luminoso suave para PuniMood.promo
  Widget _buildPromoGleam(String assetPath, double w, double h, double t) {
    return ShaderMask(
      shaderCallback: (bounds) {
        final gleamPosition = (t * 2.0) - 0.5; // Cruza la imagen
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [
            (gleamPosition - 0.2).clamp(0.0, 1.0),
            gleamPosition.clamp(0.0, 1.0),
            (gleamPosition + 0.2).clamp(0.0, 1.0),
          ],
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.7),
            Colors.white,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: _buildImage(assetPath, w, h),
    );
  }

  /// Cálculos de transformación por estado respetando las instrucciones
  _MoodTransform _calculateMoodTransform(PuniMood mood, double t) {
    switch (mood) {
      case PuniMood.splash:
      case PuniMood.waving:
        // flotación vertical ±6 px (2.4 s) + respiración 1.0 ↔ 1.025; sombra se encoge al subir
        final translateY = (math.sin(t * math.pi) * 6.0);
        final scale = 1.0 + (math.sin(t * math.pi) * 0.025);
        final shadowScale = 1.0 - (translateY / 18.0);
        return _MoodTransform(translateY: translateY, scale: scale, rotateZ: 0.0, shadowScale: shadowScale.clamp(0.75, 1.15));

      case PuniMood.discovering:
        // balanceo lateral ±1.5° y flotación leve
        final rotateZ = math.sin(t * math.pi * 2) * (1.5 * math.pi / 180);
        final translateY = math.sin(t * math.pi) * 3.5;
        return _MoodTransform(translateY: translateY, scale: 1.0, rotateZ: rotateZ, shadowScale: 0.95);

      case PuniMood.confused:
        // inclinación de cabeza oscilante ±2° con pausas
        final rotateZ = math.sin(t * math.pi * 2) * (2.0 * math.pi / 180);
        return _MoodTransform(translateY: 0.0, scale: 1.0, rotateZ: rotateZ, shadowScale: 1.0);

      case PuniMood.sad:
        // respiración lenta, escala 1.0 ↔ 1.015, baja 4 px, quieto
        final translateY = -(t * 4.0);
        final scale = 1.0 + (math.sin(t * math.pi) * 0.015);
        return _MoodTransform(translateY: translateY, scale: scale, rotateZ: 0.0, shadowScale: 1.05);

      case PuniMood.promo:
        // "pop" cada ciclo (escala 1.0 → 1.05 → 1.0)
        final scale = 1.0 + (math.sin(t * math.pi) * 0.05);
        final translateY = math.sin(t * math.pi) * 4.0;
        return _MoodTransform(translateY: translateY, scale: scale, rotateZ: 0.0, shadowScale: 0.92);

      case PuniMood.shy:
        // balanceo lento ±1° y flotación mínima
        final rotateZ = math.sin(t * math.pi * 2) * (1.0 * math.pi / 180);
        final translateY = math.sin(t * math.pi) * 2.0;
        return _MoodTransform(translateY: translateY, scale: 1.0, rotateZ: rotateZ, shadowScale: 0.98);
    }
  }
}

class _MoodTransform {
  final double translateY;
  final double scale;
  final double rotateZ;
  final double shadowScale;

  _MoodTransform({
    required this.translateY,
    required this.scale,
    required this.rotateZ,
    required this.shadowScale,
  });
}

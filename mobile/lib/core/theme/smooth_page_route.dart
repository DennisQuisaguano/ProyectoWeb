import 'package:flutter/material.dart';

/// Transición fluida, ligera y sin distorsión de escala/zoom.
/// Elimina el efecto pesado de superposición o jank entre pantallas en Android.
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothPageRoute({required this.page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 240),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.06, 0.0);
            const end = Offset.zero;
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuad,
              reverseCurve: Curves.easeInQuad,
            );

            return SlideTransition(
              position: Tween<Offset>(begin: begin, end: end).animate(curve),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
                child: child,
              ),
            );
          },
        );
}

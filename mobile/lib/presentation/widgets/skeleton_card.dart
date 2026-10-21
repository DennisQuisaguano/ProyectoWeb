import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Skeleton loader para tarjetas de locales y menús durante llamadas a la API
class SkeletonCard extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const SkeletonCard({
    super.key,
    this.height = 180,
    this.width = double.infinity,
    this.borderRadius,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withOpacity(_animation.value)
                : const Color(0xFFE2E8F0).withOpacity(_animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 14,
                  width: 140,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkBorder : Colors.white).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 90,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkBorder : Colors.white).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'custom_button.dart';
import '../../shared/widgets/puni_mascot.dart';

class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final PuniMood? puniMood;
  final String? buttonText;
  final VoidCallback? onRetry;

  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.puniMood = PuniMood.confused,
    this.buttonText,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mascota oficial 3D Puni
            if (puniMood != null)
              PuniMascot(
                mood: puniMood!,
                size: 110,
                shadow: true,
              )
            else
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.primarySubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon ?? Icons.search_off_rounded, size: 48, color: isDark ? AppColors.accentBlue : AppColors.primary),
              ),
            const SizedBox(height: 22),

            // Título amigable
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Mensaje descriptivo
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                height: 1.45,
              ),
            ),

            if (buttonText != null && onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: buttonText!,
                onPressed: onRetry,
                isOutlined: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

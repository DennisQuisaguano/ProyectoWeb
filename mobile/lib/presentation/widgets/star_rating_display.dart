import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double starSize;
  final bool showNumber;
  final Color? textColor;
  final Color? countColor;
  final bool asBadge;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.totalReviews = 0,
    this.starSize = 16,
    this.showNumber = true,
    this.textColor,
    this.countColor,
    this.asBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = textColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);
    final secondaryTextColor = countColor ?? (isDark ? AppColors.darkTextSecondary : AppColors.textMuted);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.star_rounded, size: starSize, color: AppColors.accent),
        const SizedBox(width: 4),
        if (showNumber)
          Text(
            rating > 0 ? rating.toStringAsFixed(1) : 'Nuevo',
            style: TextStyle(
              fontSize: starSize * 0.85,
              fontWeight: FontWeight.w800,
              color: primaryTextColor,
            ),
          ),
        if (totalReviews > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($totalReviews)',
            style: TextStyle(
              fontSize: starSize * 0.75,
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
            ),
          ),
        ],
      ],
    );

    if (asBadge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }
}

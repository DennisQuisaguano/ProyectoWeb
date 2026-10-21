import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import 'home/home_screen.dart';
import 'map/map_screen.dart';
import 'profile/profile_screen.dart';
import 'promotions/promotions_screen.dart';
import 'search/search_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screens = [
      HomeScreen(onNavigateTab: _onTabTapped),
      const MapScreen(),
      const SearchScreen(),
      const PromotionsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : AppColors.primaryDark.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Inicio', isDark),
                _buildNavItem(1, Icons.map_rounded, Icons.map_outlined, 'Mapa', isDark),
                _buildNavItem(2, Icons.search_rounded, Icons.search_outlined, 'Buscar', isDark),
                _buildNavItem(3, Icons.local_offer_rounded, Icons.local_offer_outlined, 'Ofertas', isDark),
                _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Perfil', isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, bool isDark) {
    final isSelected = _currentIndex == index;

    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onTabTapped(index),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 54, minHeight: 48),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 12 : 6,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.primary.withOpacity(0.25) : AppColors.primarySubtle)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? activeIcon : inactiveIcon,
                      color: isSelected
                          ? (isDark ? AppColors.accentBlue : AppColors.primary)
                          : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                      size: 23,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? AppColors.accentBlue : AppColors.primary)
                          : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

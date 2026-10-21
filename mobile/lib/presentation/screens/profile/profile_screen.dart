import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/local_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/local_card.dart';
import '../../../shared/widgets/puni_mascot.dart';
import '../auth/login_screen.dart';
import '../local_detail/local_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final location = context.watch<LocationProvider>();
    final localProv = context.watch<LocalProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = auth.currentUser;
    final favoriteLocales = localProv.locales.where((l) => localProv.favoriteIds.contains(l.id)).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mi Perfil Universitario'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Tarjeta de Identificación del Estudiante Soft UI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.2) : AppColors.primaryDark.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: auth.isAuthenticated
                  ? Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user!.nombreCompleto.isNotEmpty ? user.nombreCompleto[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.nombreCompleto,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.primarySubtle,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.primaryLight),
                          ),
                          child: Text(
                            '🎓 ${user.rol} • UTA',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.accentBlue : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const PuniMascot(
                          mood: PuniMood.waving,
                          size: 90,
                          shadow: true,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Estudiante Invitado',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Inicia sesión con tu cuenta estudiantil para calificar locales y sincronizar tus favoritos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Iniciar Sesión / Registro',
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          },
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // Opciones y Preferencias
            Material(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.school_rounded, color: isDark ? AppColors.accentBlue : AppColors.primary, size: 20),
                      ),
                      title: Text(
                        'Campus predeterminado',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        location.campusNombre,
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                      onTap: () => _showCampusPicker(context, location),
                    ),
                    Divider(height: 1, indent: 56, color: isDark ? AppColors.darkBorder : AppColors.border),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.notifications_active_rounded, color: isDark ? AppColors.accentBlue : AppColors.primary, size: 20),
                      ),
                      title: Text(
                        'Avisos de Promociones',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Recibir ofertas y descuentos del día',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                      trailing: Switch(
                        value: true,
                        activeColor: isDark ? AppColors.accentBlue : AppColors.primary,
                        onChanged: (val) {},
                      ),
                    ),
                    Divider(height: 1, indent: 56, color: isDark ? AppColors.darkBorder : AppColors.border),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.info_outline_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, size: 20),
                      ),
                      title: Text(
                        'Plataforma Gastronómica UTA',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Versión 1.0.0 • Comunidad Universitaria',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Sección: Locales Guardados / Favoritos
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Text('❤️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    'Locales Guardados (${favoriteLocales.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            if (favoriteLocales.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: Column(
                  children: [
                    const PuniMascot(
                      mood: PuniMood.discovering,
                      size: 90,
                      shadow: true,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Aún no has guardado locales favoritos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toca el corazón en cualquier local para tenerlo a mano siempre.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...favoriteLocales.map((l) {
                return LocalCard(
                  local: l,
                  isFavorite: true,
                  onToggleFavorite: () => localProv.toggleFavorite(l.id),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LocalDetailScreen(localId: l.id)),
                    );
                  },
                );
              }),

            const SizedBox(height: 24),

            if (auth.isAuthenticated)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => auth.logout(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCampusPicker(BuildContext context, LocationProvider location) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                'Selecciona tu Campus UTA',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ),
            ...AppConstants.campusNames.entries.map((entry) {
              final isSelected = location.selectedCampusId == entry.key;
              return ListTile(
                title: Text(
                  entry.value,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                onTap: () {
                  location.setCampus(entry.key);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

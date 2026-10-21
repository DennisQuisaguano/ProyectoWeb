import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notificacion_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../../shared/widgets/puni_mascot.dart';
import '../../widgets/skeleton_card.dart';
import '../auth/login_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificacionProvider>().fetchNotificaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notif = context.watch<NotificacionProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Notificaciones'),
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          elevation: 0,
        ),
        body: EmptyStateView(
          icon: Icons.notifications_none_rounded,
          title: 'Inicia sesión para recibir avisos',
          message: 'Recibe alertas inmediatas cuando tus locales cercanos publiquen promociones y descuentos.',
          buttonText: 'Iniciar Sesión',
          onRetry: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Avisos y Promociones'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (notif.notificaciones.isNotEmpty)
            TextButton(
              onPressed: () => notif.markAllAsRead(),
              child: Text('Marcar leídas', style: TextStyle(color: isDark ? AppColors.accentBlue : AppColors.primary)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notif.fetchNotificaciones(),
        color: AppColors.primary,
        child: notif.isLoading
            ? ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: 4,
                itemBuilder: (_, __) => const SkeletonCard(height: 75),
              )
            : notif.notificaciones.isEmpty
                ? const EmptyStateView(
                    puniMood: PuniMood.waving,
                    title: 'No tienes avisos pendientes',
                    message: 'Te avisaremos tan pronto haya ofertas especiales en los restaurantes de la UTA.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: notif.notificaciones.length,
                    itemBuilder: (context, index) {
                      final n = notif.notificaciones[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.local_offer_rounded, color: isDark ? AppColors.accentBlue : AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n.titulo,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        n.formattedFecha,
                                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n.mensaje,
                                    style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

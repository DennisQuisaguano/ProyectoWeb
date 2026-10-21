import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/location_provider.dart';
import '../../providers/promocion_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/promotion_card.dart';
import '../../../shared/widgets/puni_mascot.dart';
import '../../widgets/skeleton_card.dart';
import '../local_detail/local_detail_screen.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPromos();
    });
  }

  Future<void> _loadPromos() async {
    final location = context.read<LocationProvider>();
    context.read<PromocionProvider>().fetchGlobalPromotions(
      campus: location.selectedCampusId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final promo = context.watch<PromocionProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('🔥 Ofertas Universitarias'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadPromos,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPromos,
        color: AppColors.primary,
        child: promo.isLoading
            ? ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                itemCount: 3,
                itemBuilder: (_, __) => const SkeletonCard(height: 190),
              )
            : promo.globalPromotions.isEmpty
                ? EmptyStateView(
                    puniMood: PuniMood.promo,
                    title: 'Puni no encontró ofertas hoy',
                    message: 'Los locales de ${location.campusNombre} no han publicado nuevas promociones el día de hoy.',
                    buttonText: 'Actualizar ofertas',
                    onRetry: _loadPromos,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    itemCount: promo.globalPromotions.length,
                    itemBuilder: (context, index) {
                      final p = promo.globalPromotions[index];
                      return PromotionCard(
                        promocion: p,
                        onTap: () {
                          promo.registrarClickPromocion(p.localId, p.titulo);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LocalDetailScreen(localId: p.localId),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

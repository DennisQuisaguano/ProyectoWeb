import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/smooth_page_route.dart';
import '../../../data/models/local_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/local_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/promocion_provider.dart';
import '../../../shared/widgets/puni_mascot.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/local_card.dart';
import '../../widgets/novedad_hoy_card.dart';
import '../../widgets/skeleton_card.dart';
import '../local_detail/local_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final location = context.read<LocationProvider>();
    final localProvider = context.read<LocalProvider>();
    final promoProvider = context.read<PromocionProvider>();
    final menuProvider = context.read<MenuProvider>();

    // 1. Cargar campus guardado y favoritos de SharedPreferences inmediatamente (<5ms)
    await Future.wait([
      location.initLocation(waitForGps: false),
      localProvider.initFavorites(),
    ]);

    final campusId = location.selectedCampusId;
    final userLat = location.referenceLatitude;
    final userLng = location.referenceLongitude;

    // 2. Disparar peticiones HTTP de locales y promociones de inmediato en paralelo
    final fetchFuture = Future.wait([
      localProvider.fetchLocales(
        campus: campusId,
        userLat: userLat,
        userLng: userLng,
      ),
      promoProvider.fetchGlobalPromotions(campus: campusId),
      menuProvider.fetchPlatosDelDia(campus: campusId),
    ]);

    // 3. Obtener GPS en segundo plano y refrescar distancias cuando responda el sensor
    location.fetchUserLocation().then((pos) {
      if (pos != null && mounted) {
        localProvider.updateDistances(pos.latitude, pos.longitude);
      }
    });

    await fetchFuture;
  }

  void _onCampusChanged(int campusId) async {
    final location = context.read<LocationProvider>();
    final local = context.read<LocalProvider>();
    final promo = context.read<PromocionProvider>();
    final menu = context.read<MenuProvider>();

    await location.setCampus(campusId);
    local.setFilterCampus(campusId);

    local.fetchLocales(
      campus: campusId,
      userLat: location.referenceLatitude,
      userLng: location.referenceLongitude,
    );
    promo.fetchGlobalPromotions(campus: campusId);
    menu.fetchPlatosDelDia(campus: campusId);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final location = context.watch<LocationProvider>();
    final local = context.watch<LocalProvider>();
    final promo = context.watch<PromocionProvider>();
    final menu = context.watch<MenuProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final novedades = NovedadHoy.intercalar(promo.globalPromotions, menu.platosDelDiaGlobal);

    final studentName = auth.currentUser?.nombreCompleto.split(' ').first ?? 'Estudiante';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Dashboard Header Moderno (Azul + Blanco / Dark Mode)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fila superior: Saludo + Selector de Campus
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const PuniMascot(
                                  mood: PuniMood.waving,
                                  size: 66,
                                  shadow: false,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '¡Hola, $studentName!',
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800,
                                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                                letterSpacing: -0.3,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text('👋', style: TextStyle(fontSize: 15)),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '¿Qué quieres comer hoy?',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Selector Popup de Campus UTA Soft UI
                          PopupMenuButton<int>(
                            onSelected: _onCampusChanged,
                            color: theme.cardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.primaryLight),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.school_rounded, size: 14, color: isDark ? AppColors.accentBlue : AppColors.primary),
                                  const SizedBox(width: 4),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 85),
                                    child: Text(
                                      location.campusNombre.replaceAll('Campus ', ''),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.accentBlue : AppColors.primary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: isDark ? AppColors.accentBlue : AppColors.primary),
                                ],
                              ),
                            ),
                            itemBuilder: (_) => AppConstants.campusNames.entries.map((entry) {
                              final isSelected = location.selectedCampusId == entry.key;
                              return PopupMenuItem<int>(
                                value: entry.key,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 16,
                                      color: isSelected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected
                                            ? (isDark ? AppColors.accentBlue : AppColors.primary)
                                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Buscador Rápido interactivo que abre directamente la pestaña de Búsqueda completa
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onNavigateTab?.call(2); // Navega al tab Buscar
                          },
                          child: Ink(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.border,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: isDark ? AppColors.accentBlue : AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Buscar platos, almuerzos, locales...',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.primarySubtle.withOpacity(0.15) : AppColors.primarySubtle,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.tune_rounded,
                                        size: 14,
                                        color: isDark ? AppColors.accentBlue : AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Filtros',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.accentBlue : AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Banner de Estado GPS (si está inactivo)
              if (location.permissionDenied && location.currentPosition == null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.primaryLight),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.near_me_outlined, color: isDark ? AppColors.accentBlue : AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Distancias calculadas respecto al campus seleccionado.',
                            style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark),
                          ),
                        ),
                        TextButton(
                          onPressed: () => location.fetchUserLocation(),
                          child: Text(
                            'Activar GPS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.accentBlue : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. Carrusel único "Hoy": ofertas vigentes + platos del día
              if (novedades.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hoy en tu campus',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (widget.onNavigateTab != null && promo.globalPromotions.isNotEmpty)
                          TextButton(
                            onPressed: () => widget.onNavigateTab!(3),
                            child: Text(
                              'Ver ofertas →',
                              style: TextStyle(
                                color: isDark ? AppColors.accentBlue : AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 196,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: novedades.length,
                      itemBuilder: (context, index) {
                        final n = novedades[index];
                        return NovedadHoyCard(
                          novedad: n,
                          onTap: () {
                            if (n.esOferta) {
                              promo.registrarClickPromocion(n.localId, n.titulo);
                            }
                            final localMatch = local.locales.cast<LocalModel?>().firstWhere(
                              (item) => item?.id == n.localId,
                              orElse: () => null,
                            );
                            Navigator.push(
                              context,
                              SmoothPageRoute(
                                page: LocalDetailScreen(
                                  localId: n.localId,
                                  initialLocal: localMatch,
                                  initialTab: n.esOferta ? 1 : 0,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],

              // 4. Categorías en una sola fila compacta
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                  child: SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 16),
                      children: [
                        _buildCategoryChip(
                          label: 'Todos',
                          icon: '🍴',
                          isSelected: local.filterCategoria == null,
                          isDark: isDark,
                          onTap: () => local.setFilterCategoria(null),
                        ),
                        ...AppConstants.categoriasLocal.entries.map((entry) {
                          final isSelected = local.filterCategoria == entry.key;
                          final icon = AppConstants.categoriaIconos[entry.key] ?? '🍽️';
                          return _buildCategoryChip(
                            label: entry.value,
                            icon: icon,
                            isSelected: isSelected,
                            isDark: isDark,
                            onTap: () => local.setFilterCategoria(isSelected ? null : entry.key),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // 5. Locales: título + orden (Más cercanos / Mejor valorados)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Locales (${local.filteredLocales.length})',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Row(
                        children: [
                          _buildSortChip(
                            label: 'Cercanos',
                            isSelected: local.sortOrder == LocalSortOrder.cercanos,
                            isDark: isDark,
                            onTap: () => local.setSortOrder(LocalSortOrder.cercanos),
                          ),
                          const SizedBox(width: 6),
                          _buildSortChip(
                            label: 'Mejor valorados',
                            isSelected: local.sortOrder == LocalSortOrder.mejorValorados,
                            isDark: isDark,
                            onTap: () => local.setSortOrder(LocalSortOrder.mejorValorados),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Lista o Estados (Skeleton / Empty / Results)
              if (local.isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const SkeletonCard(height: 190),
                      childCount: 4,
                    ),
                  ),
                )
              else if (local.filteredLocales.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyStateView(
                    puniMood: PuniMood.confused,
                    title: 'Puni está buscando...',
                    message: 'No encontramos locales con esos filtros en tu campus.\nPrueba cambiando de categoría.',
                    buttonText: 'Restablecer filtros',
                    onRetry: () {
                      local.resetFilters();
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final l = local.filteredLocales[index];
                        return LocalCard(
                          isCompact: true,
                          local: l,
                          isFavorite: local.favoriteIds.contains(l.id),
                          onToggleFavorite: () => local.toggleFavorite(l.id),
                          onTap: () {
                            Navigator.push(
                              context,
                              SmoothPageRoute(
                                page: LocalDetailScreen(localId: l.id, initialLocal: l),
                              ),
                            );
                          },
                        );
                      },
                      childCount: local.filteredLocales.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final acento = isDark ? AppColors.accentBlue : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 32),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? acento.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? acento : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required String icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryVibrant : AppColors.primary)
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.primaryVibrant : AppColors.primary)
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

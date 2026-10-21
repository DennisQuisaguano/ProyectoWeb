import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/local_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/promocion_provider.dart';
import '../../../shared/widgets/puni_mascot.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/local_card.dart';
import '../../widgets/promotion_card.dart';
import '../../widgets/skeleton_card.dart';
import '../local_detail/local_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final location = context.read<LocationProvider>();
    final localProvider = context.read<LocalProvider>();
    final promoProvider = context.read<PromocionProvider>();

    await location.initLocation();
    await localProvider.initFavorites();

    final userLat = location.referenceLatitude;
    final userLng = location.referenceLongitude;

    await Future.wait([
      localProvider.fetchLocales(
        campus: location.selectedCampusId,
        userLat: userLat,
        userLng: userLng,
      ),
      promoProvider.fetchGlobalPromotions(campus: location.selectedCampusId),
    ]);
  }

  void _onCampusChanged(int campusId) async {
    final location = context.read<LocationProvider>();
    final local = context.read<LocalProvider>();
    final promo = context.read<PromocionProvider>();

    await location.setCampus(campusId);
    local.setFilterCampus(campusId);

    local.fetchLocales(
      campus: campusId,
      userLat: location.referenceLatitude,
      userLng: location.referenceLongitude,
    );
    promo.fetchGlobalPromotions(campus: campusId);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final location = context.watch<LocationProvider>();
    final local = context.watch<LocalProvider>();
    final promo = context.watch<PromocionProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

                      // Barra de búsqueda y Filtros Soft UI
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.background,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) => local.setSearchQuery(val),
                                style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Buscar hamburguesas, almuerzos...',
                                  hintStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                                  prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppColors.accentBlue : AppColors.primary, size: 22),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.close_rounded, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                                          onPressed: () {
                                            _searchController.clear();
                                            local.setSearchQuery('');
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: (local.filterCategoria != null ||
                                      local.filterSoloAbiertos ||
                                      local.filterPresupuestoMax != null ||
                                      local.filterSoloComidaRapida)
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkSurface : AppColors.background),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: (local.filterCategoria != null ||
                                        local.filterSoloAbiertos ||
                                        local.filterPresupuestoMax != null ||
                                        local.filterSoloComidaRapida)
                                    ? AppColors.primary
                                    : (isDark ? AppColors.darkBorder : AppColors.border),
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.tune_rounded,
                                size: 20,
                                color: (local.filterCategoria != null ||
                                        local.filterSoloAbiertos ||
                                        local.filterPresupuestoMax != null ||
                                        local.filterSoloComidaRapida)
                                    ? Colors.white
                                    : (isDark ? AppColors.accentBlue : AppColors.primary),
                              ),
                              onPressed: () => FilterBottomSheet.show(context, local),
                            ),
                          ),
                        ],
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

              // 3. Categorías de Comida con Chips Modernos Soft UI
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categorías',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
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
                    ],
                  ),
                ),
              ),

              // 4. Sección: Ofertas de Hoy / Promociones
              if (promo.globalPromotions.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              'Ofertas de Hoy',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        if (widget.onNavigateTab != null)
                          TextButton(
                            onPressed: () => widget.onNavigateTab!(3),
                            child: Text(
                              'Ver todas →',
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
                    height: 275,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: promo.globalPromotions.length,
                      itemBuilder: (context, index) {
                        final p = promo.globalPromotions[index];
                        return Container(
                          width: 280,
                          margin: const EdgeInsets.only(right: 14),
                          child: PromotionCard(
                            promocion: p,
                            isCompact: true,
                            onTap: () {
                              promo.registrarClickPromocion(p.localId, p.titulo);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LocalDetailScreen(localId: p.localId),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // 5. Sección: Recomendado para ti (Puni sugiere)
              if (local.recommendedLocales.isNotEmpty &&
                  local.filterCategoria == null &&
                  _searchController.text.isEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          'Recomendado para ti',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.primarySubtle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Puni Top ⭐',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.accentBlue : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final l = local.recommendedLocales[index];
                        return LocalCard(
                          local: l,
                          isFavorite: local.favoriteIds.contains(l.id),
                          onToggleFavorite: () => local.toggleFavorite(l.id),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LocalDetailScreen(localId: l.id)),
                            );
                          },
                        );
                      },
                      childCount: local.recommendedLocales.take(3).length,
                    ),
                  ),
                ),
              ],

              // 6. Sección: Locales Cercanos al Campus
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        local.filterCategoria != null
                            ? 'Locales filtrados (${local.filteredLocales.length})'
                            : 'Locales cercanos al campus (${local.filteredLocales.length})',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
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
                    message: 'No encontramos locales con esos filtros en tu campus.\nPrueba cambiando tu búsqueda o seleccionando otra categoría.',
                    buttonText: 'Restablecer filtros',
                    onRetry: () {
                      _searchController.clear();
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
                          local: l,
                          isFavorite: local.favoriteIds.contains(l.id),
                          onToggleFavorite: () => local.toggleFavorite(l.id),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LocalDetailScreen(localId: l.id)),
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

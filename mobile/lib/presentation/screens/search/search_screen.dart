import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/smooth_page_route.dart';
import '../../../data/models/local_model.dart';
import '../../providers/local_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/dish_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/local_card.dart';
import '../../../shared/widgets/puni_mascot.dart';
import '../../widgets/skeleton_card.dart';
import '../local_detail/local_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  double? _selectedBudgetFilter;

  final List<String> _quickSearches = [
    'Almuerzo',
    'Hamburguesa',
    'Pizza',
    'Café',
    'Empanadas',
    'Seco de Pollo',
    'Desayunos',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executeSearch('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _executeSearch(String query) {
    final location = context.read<LocationProvider>();
    final menuProvider = context.read<MenuProvider>();
    final localProvider = context.read<LocalProvider>();

    localProvider.setSearchQuery(query);

    // Si query está vacío y no hay presupuesto forzado, traemos todos los platos disponibles
    menuProvider.searchDishes(
      query: query.trim(),
      campus: (_selectedBudgetFilter != null || query.trim().isNotEmpty) ? location.selectedCampusId : null,
      precioMaximo: _selectedBudgetFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final local = context.watch<LocalProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Descubrir Comida'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.accentBlue : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          indicatorColor: isDark ? AppColors.accentBlue : AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(text: '🍲 Platos (${menu.searchResults.length})'),
            Tab(text: '🏪 Locales (${local.filteredLocales.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header de Búsqueda Soft UI
          Container(
            color: theme.cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _executeSearch,
                    onSubmitted: _executeSearch,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '¿Qué se te antoja hoy? (ej. almuerzo, pizza)',
                      hintStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                      prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppColors.accentBlue : AppColors.primary, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                _executeSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filtro rápido de presupuesto estudiantil
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Icon(Icons.attach_money_rounded, size: 16, color: isDark ? AppColors.accentBlue : AppColors.primary),
                      Text(
                        'Presupuesto: ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _buildBudgetChip('Cualquiera', null, isDark),
                      _buildBudgetChip('< \$2.00', 2.0, isDark),
                      _buildBudgetChip('< \$3.00', 3.0, isDark),
                      _buildBudgetChip('< \$5.00', 5.0, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Sugerencias rápidas
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickSearches.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                            ),
                          ),
                          backgroundColor: isDark ? AppColors.darkSurface : AppColors.primarySubtle,
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.primaryLight),
                          onPressed: () {
                            _searchController.text = tag;
                            _executeSearch(tag);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Contenido de Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDishesTab(menu),
                _buildLocalesTab(local),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetChip(String label, double? budget, bool isDark) {
    final isSelected = _selectedBudgetFilter == budget;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: isDark ? AppColors.accentBlue : AppColors.primary,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        side: BorderSide(
          color: isSelected
              ? (isDark ? AppColors.accentBlue : AppColors.primary)
              : (isDark ? AppColors.darkBorder : AppColors.border),
        ),
        labelStyle: TextStyle(
          color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (val) {
          setState(() {
            _selectedBudgetFilter = val ? budget : null;
          });
          _executeSearch(_searchController.text);
        },
      ),
    );
  }

  Widget _buildDishesTab(MenuProvider menu) {
    if (menu.isSearching) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => const SkeletonCard(height: 120),
      );
    }

    if (menu.searchResults.isEmpty) {
      return EmptyStateView(
        puniMood: PuniMood.confused,
        title: 'Puni no encontró ese plato',
        message: 'No encontramos platos con ese nombre o presupuesto.\nPrueba con otra palabra o aumenta el presupuesto máximo.',
        buttonText: 'Buscar Almuerzos',
        onRetry: () {
          _searchController.text = 'Almuerzo';
          _executeSearch('Almuerzo');
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: menu.searchResults.length,
      itemBuilder: (context, index) {
        final p = menu.searchResults[index];
        return DishCard(
          plato: p,
          onTapLocal: () {
            final localProv = context.read<LocalProvider>();
            final localMatch = localProv.locales.cast<LocalModel?>().firstWhere(
              (item) => item?.id == p.localId,
              orElse: () => null,
            );
            Navigator.push(
              context,
              SmoothPageRoute(
                page: LocalDetailScreen(localId: p.localId, initialLocal: localMatch),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLocalesTab(LocalProvider local) {
    if (local.filteredLocales.isEmpty) {
      return EmptyStateView(
        puniMood: PuniMood.confused,
        title: 'No encontramos locales',
        message: 'No existen locales gastronómicos que coincidan con "${_searchController.text}".',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: local.filteredLocales.length,
      itemBuilder: (context, index) {
        final l = local.filteredLocales[index];
        return LocalCard(
          local: l,
          isFavorite: local.favoriteIds.contains(l.id),
          onToggleFavorite: () => local.toggleFavorite(l.id),
          onTap: () {
            Navigator.push(
              context,
              SmoothPageRoute(page: LocalDetailScreen(localId: l.id, initialLocal: l)),
            );
          },
        );
      },
    );
  }
}

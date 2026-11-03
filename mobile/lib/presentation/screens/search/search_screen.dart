import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/smooth_page_route.dart';
import '../../../data/models/local_model.dart';
import '../../../data/models/plato_model.dart';
import '../../providers/local_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/promocion_provider.dart';
import '../../widgets/dish_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../../shared/widgets/puni_mascot.dart';
import '../../widgets/skeleton_card.dart';
import '../local_detail/local_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  double? _selectedBudgetFilter;
  bool _soloPlatoDelDia = false;
  bool _soloConOferta = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final promo = context.read<PromocionProvider>();
      if (promo.globalPromotions.isEmpty) {
        promo.fetchGlobalPromotions(campus: context.read<LocationProvider>().selectedCampusId);
      }
      _executeSearch('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      soloPlatoDelDia: _soloPlatoDelDia,
    );
  }

  void _openLocal(String localId, {int initialTab = 0}) {
    final localMatch = context.read<LocalProvider>().locales.cast<LocalModel?>().firstWhere(
          (item) => item?.id == localId,
          orElse: () => null,
        );
    Navigator.push(
      context,
      SmoothPageRoute(
        page: LocalDetailScreen(localId: localId, initialLocal: localMatch, initialTab: initialTab),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final local = context.watch<LocalProvider>();
    final promo = context.watch<PromocionProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hayTexto = _searchController.text.trim().isNotEmpty;

    final platosConOferta = promo.globalPromotions.map((p) => p.platoId).whereType<String>().toSet();
    final resultados = _soloConOferta
        ? menu.searchResults.where((p) => platosConOferta.contains(p.id)).toList()
        : menu.searchResults;

    // Locales que coinciden con el texto (solo se muestran al escribir)
    final localesCoinciden = hayTexto ? local.filteredLocales.take(8).toList() : <LocalModel>[];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Descubrir Comida'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: theme.cardColor,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
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
                    onChanged: (value) {
                      setState(() {});
                      _executeSearch(value);
                    },
                    onSubmitted: _executeSearch,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '¿Qué se te antoja hoy? (ej. almuerzo, pizza)',
                      hintStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                      prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppColors.accentBlue : AppColors.primary, size: 22),
                      suffixIcon: hayTexto
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
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

                // Una sola fila de filtros: presupuesto, plato del día y con oferta
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildToggleChip(
                        label: '⭐ Del día',
                        isSelected: _soloPlatoDelDia,
                        isDark: isDark,
                        onSelected: (val) {
                          setState(() => _soloPlatoDelDia = val);
                          _executeSearch(_searchController.text);
                        },
                      ),
                      _buildToggleChip(
                        label: '🔥 Con oferta',
                        isSelected: _soloConOferta,
                        isDark: isDark,
                        onSelected: (val) => setState(() => _soloConOferta = val),
                      ),
                      _buildBudgetChip('< \$2', 2.0, isDark),
                      _buildBudgetChip('< \$3', 3.0, isDark),
                      _buildBudgetChip('< \$5', 5.0, isDark),
                    ],
                  ),
                ),

                // Sugerencias: solo cuando todavía no se escribió nada
                if (!hayTexto) ...[
                  const SizedBox(height: 8),
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
                              setState(() {});
                              _executeSearch(tag);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(child: _buildResults(menu, resultados, localesCoinciden, isDark)),
        ],
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required ValueChanged<bool> onSelected,
  }) {
    final acento = isDark ? AppColors.accentBlue : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        selectedColor: acento,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        side: BorderSide(color: isSelected ? acento : (isDark ? AppColors.darkBorder : AppColors.border)),
        labelStyle: TextStyle(
          color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
        onSelected: onSelected,
      ),
    );
  }

  Widget _buildBudgetChip(String label, double budget, bool isDark) {
    return _buildToggleChip(
      label: label,
      isSelected: _selectedBudgetFilter == budget,
      isDark: isDark,
      onSelected: (val) {
        setState(() => _selectedBudgetFilter = val ? budget : null);
        _executeSearch(_searchController.text);
      },
    );
  }

  Widget _buildResults(MenuProvider menu, List<PlatoModel> resultados, List<LocalModel> localesCoinciden, bool isDark) {
    if (menu.isSearching) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => const SkeletonCard(height: 120),
      );
    }

    if (resultados.isEmpty && localesCoinciden.isEmpty) {
      return EmptyStateView(
        puniMood: PuniMood.confused,
        title: 'Puni no encontró ese plato',
        message: 'No encontramos platos con ese nombre o filtros.\nPrueba con otra palabra o quita algún filtro.',
        buttonText: 'Buscar Almuerzos',
        onRetry: () {
          setState(() {
            _soloPlatoDelDia = false;
            _soloConOferta = false;
            _selectedBudgetFilter = null;
          });
          _searchController.text = 'Almuerzo';
          _executeSearch('Almuerzo');
        },
      );
    }

    final titleStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (localesCoinciden.isNotEmpty) ...[
          Text('Locales (${localesCoinciden.length})', style: titleStyle),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: localesCoinciden.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final l = localesCoinciden[index];
                return ActionChip(
                  avatar: Text(l.categoriaIcono),
                  label: Text(l.nombre),
                  onPressed: () => _openLocal(l.id),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (resultados.isNotEmpty) ...[
          Text('Platos (${resultados.length})', style: titleStyle),
          const SizedBox(height: 8),
          ...resultados.map(
            (p) => DishCard(
              plato: p,
              onTapLocal: () => _openLocal(p.localId),
            ),
          ),
        ],
      ],
    );
  }
}

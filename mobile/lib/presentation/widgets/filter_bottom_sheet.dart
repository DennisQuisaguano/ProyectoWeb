import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../providers/local_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  final LocalProvider provider;

  const FilterBottomSheet({super.key, required this.provider});

  static void show(BuildContext context, LocalProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(provider: provider),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int? _selectedCampus;
  int? _selectedCategoria;
  double? _selectedMaxDistance;
  double? _selectedBudget;
  bool _soloAbiertos = false;
  bool _soloComidaRapida = false;

  @override
  void initState() {
    super.initState();
    _selectedCampus = widget.provider.filterCampus;
    _selectedCategoria = widget.provider.filterCategoria;
    _selectedMaxDistance = widget.provider.filterMaxDistanciaMeters;
    _selectedBudget = widget.provider.filterPresupuestoMax;
    _soloAbiertos = widget.provider.filterSoloAbiertos;
    _soloComidaRapida = widget.provider.filterSoloComidaRapida;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con barra y títulos
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros Inteligentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCampus = null;
                    _selectedCategoria = null;
                    _selectedMaxDistance = null;
                    _selectedBudget = null;
                    _soloAbiertos = false;
                    _soloComidaRapida = false;
                  });
                },
                child: Text('Limpiar todo', style: TextStyle(color: isDark ? AppColors.accentBlue : AppColors.primary)),
              ),
            ],
          ),
          Divider(color: isDark ? AppColors.darkBorder : AppColors.border),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Campus UTA
                  _buildSectionTitle('Campus UTA', isDark),
                  Wrap(
                    spacing: 8,
                    children: AppConstants.campusNames.entries.map((entry) {
                      final isSelected = _selectedCampus == entry.key;
                      return ChoiceChip(
                        label: Text(entry.value),
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
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setState(() {
                            _selectedCampus = val ? entry.key : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 2. Presupuesto
                  _buildSectionTitle('💰 Presupuesto', isDark),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildChip('Menos de \$2', _selectedBudget == 2.0, () {
                        setState(() => _selectedBudget = _selectedBudget == 2.0 ? null : 2.0);
                      }, isDark),
                      _buildChip('Menos de \$3', _selectedBudget == 3.0, () {
                        setState(() => _selectedBudget = _selectedBudget == 3.0 ? null : 3.0);
                      }, isDark),
                      _buildChip('Menos de \$5', _selectedBudget == 5.0, () {
                        setState(() => _selectedBudget = _selectedBudget == 5.0 ? null : 5.0);
                      }, isDark),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3. Tiempo disponible / Rapidez
                  _buildSectionTitle('⏱️ Tiempo disponible', isDark),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildChip('⚡ Comida Rápida (< 15 min)', _soloComidaRapida, () {
                        setState(() => _soloComidaRapida = !_soloComidaRapida);
                      }, isDark),
                      _buildChip('🟢 Solo locales Abiertos ahora', _soloAbiertos, () {
                        setState(() => _soloAbiertos = !_soloAbiertos);
                      }, isDark),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 4. Distancia máxima
                  _buildSectionTitle('📍 Cercanía', isDark),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildChip('< 300 m (A pasos)', _selectedMaxDistance == 300.0, () {
                        setState(() => _selectedMaxDistance = _selectedMaxDistance == 300.0 ? null : 300.0);
                      }, isDark),
                      _buildChip('< 700 m (~8 min)', _selectedMaxDistance == 700.0, () {
                        setState(() => _selectedMaxDistance = _selectedMaxDistance == 700.0 ? null : 700.0);
                      }, isDark),
                      _buildChip('< 1.5 km (~15 min)', _selectedMaxDistance == 1500.0, () {
                        setState(() => _selectedMaxDistance = _selectedMaxDistance == 1500.0 ? null : 1500.0);
                      }, isDark),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 5. Categoría
                  _buildSectionTitle('🍴 Categoría', isDark),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: AppConstants.categoriasLocal.entries.map((entry) {
                      final isSelected = _selectedCategoria == entry.key;
                      final icon = AppConstants.categoriaIconos[entry.key] ?? '🍽️';
                      return FilterChip(
                        label: Text('$icon ${entry.value}'),
                        selected: isSelected,
                        selectedColor: isDark ? AppColors.accentBlue.withOpacity(0.3) : AppColors.primaryLight,
                        checkmarkColor: isDark ? AppColors.accentBlue : AppColors.primary,
                        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                        side: BorderSide(
                          color: isSelected
                              ? (isDark ? AppColors.accentBlue : AppColors.primary)
                              : (isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? (isDark ? AppColors.accentBlue : AppColors.primary)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setState(() {
                            _selectedCategoria = val ? entry.key : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Botón Aplicar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.provider.setFilterCampus(_selectedCampus);
                widget.provider.setFilterCategoria(_selectedCategoria);
                widget.provider.setFilterMaxDistancia(_selectedMaxDistance);
                widget.provider.setFilterPresupuesto(_selectedBudget);
                widget.provider.setFilterSoloAbiertos(_soloAbiertos);
                widget.provider.setFilterSoloComidaRapida(_soloComidaRapida);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.accentBlue : AppColors.primary,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Aplicar Filtros',
                style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onSelected, bool isDark) {
    return ChoiceChip(
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
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

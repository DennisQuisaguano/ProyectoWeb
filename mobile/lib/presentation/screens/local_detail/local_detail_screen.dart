import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/local_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/local_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/promocion_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/dish_card.dart';
import '../../widgets/in_app_route_modal.dart';
import '../../widgets/promotion_card.dart';
import '../../widgets/star_rating_display.dart';
import '../../../shared/widgets/puni_mascot.dart';
import '../auth/login_screen.dart';

class LocalDetailScreen extends StatefulWidget {
  final String localId;
  final LocalModel? initialLocal;

  /// Pestaña inicial: 0 = Menú, 1 = Ofertas, 2 = Reseñas.
  final int initialTab;

  const LocalDetailScreen({
    super.key,
    required this.localId,
    this.initialLocal,
    this.initialTab = 0,
  });

  @override
  State<LocalDetailScreen> createState() => _LocalDetailScreenState();
}

class _LocalDetailScreenState extends State<LocalDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _descripcionExpandida = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab.clamp(0, 2));
    // Esperar a que concluya la transición de entrada para asegurar 120 FPS sin bloqueos en el hilo principal
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _loadDetails();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    final location = context.read<LocationProvider>();
    final localProvider = context.read<LocalProvider>();
    final menuProvider = context.read<MenuProvider>();
    final promoProvider = context.read<PromocionProvider>();

    final userLat = location.referenceLatitude;
    final userLng = location.referenceLongitude;

    await Future.wait([
      localProvider.fetchLocalDetail(widget.localId, userLat: userLat, userLng: userLng),
      menuProvider.fetchDishesByLocal(widget.localId),
      promoProvider.fetchPromotionsByLocal(widget.localId),
    ]);
  }

  void _openWhatsApp(String phone, String localNombre) async {
    HapticFeedback.lightImpact();
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Número de WhatsApp no válido')),
        );
      }
      return;
    }

    // Normalización para Ecuador (+593): si empieza con '09...', quitar 0 y anteponer 593.
    // Si tiene 9 dígitos ('9...'), anteponer 593. Si ya tiene '593...', mantenerlo.
    String fullNumber;
    if (cleanPhone.startsWith('593')) {
      fullNumber = cleanPhone;
    } else if (cleanPhone.startsWith('0')) {
      fullNumber = '593${cleanPhone.substring(1)}';
    } else if (cleanPhone.length == 9) {
      fullNumber = '593$cleanPhone';
    } else {
      fullNumber = cleanPhone;
    }

    context.read<LocalProvider>().registrarContacto(widget.localId, isWhatsApp: true);

    final encodedText = Uri.encodeComponent('Hola, vi su local $localNombre en la App UTA Gastronomía');
    final appUri = Uri.parse('whatsapp://send?phone=$fullNumber&text=$encodedText');
    final webUri = Uri.parse('https://wa.me/$fullNumber?text=$encodedText');

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      // Fallback seguro a navegador web externo
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir WhatsApp en este dispositivo')),
          );
        }
      }
    }
  }

  void _openPhoneCall(String phone) async {
    HapticFeedback.lightImpact();
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final url = Uri.parse('tel:$clean');
    context.read<LocalProvider>().registrarContacto(widget.localId, isWhatsApp: false);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar la llamada')),
        );
      }
    }
  }

  void _showRouteModal(BuildContext context, LocalModel local, double userLat, double userLng) {
    HapticFeedback.lightImpact();
    InAppRouteModal.show(
      context: context,
      userPoint: LatLng(userLat, userLng),
      localPoint: LatLng(local.latitud, local.longitud),
      localNombre: local.nombre,
      categoriaIcono: local.categoriaIcono,
    );
  }

  void _showAddReviewDialog() {
    HapticFeedback.lightImpact();
    final auth = context.read<AuthProvider>();

    if (!auth.isAuthenticated) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Iniciar Sesión'),
          content: const Text('Debes iniciar sesión con tu cuenta estudiantil para poder calificar este local.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Ingresar'),
            ),
          ],
        ),
      );
      return;
    }

    int selectedStars = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final surfaceColor = Theme.of(context).colorScheme.surface;

          return Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    'Calificar Establecimiento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tu opinión ayuda a otros estudiantes de la UTA',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Selector de estrellas con Touch Target >= 48dp y Haptic Feedback
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return Semantics(
                          label: '$starIndex estrellas',
                          button: true,
                          child: InkResponse(
                            radius: 24,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModalState(() => selectedStars = starIndex);
                            },
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: Icon(
                                  starIndex <= selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                                  size: 38,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Comentario
                  Text(
                    'Comentario u opinión',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: '¿Qué tal la comida, precios y atención?',
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Publicar Reseña',
                      onPressed: () async {
                        if (selectedStars < 1 || selectedStars > 5) return;
                        HapticFeedback.lightImpact();

                        Navigator.pop(ctx);
                        final localProv = this.context.read<LocalProvider>();
                        final ok = await localProv.addResena(
                          localId: widget.localId,
                          calificacion: selectedStars,
                          comentario: commentController.text,
                        );

                        if (ok && mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Reseña publicada con éxito! Gracias por tu aporte.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } else if (mounted && localProv.errorMessage != null) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(localProv.errorMessage!),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localProv = context.watch<LocalProvider>();
    final menuProv = context.watch<MenuProvider>();
    final promoProv = context.watch<PromocionProvider>();

    // 1. Obtener datos del local de inmediato (cache del provider, parámetro o selectedLocal)
    final LocalModel? maybeLocal = (localProv.selectedLocal != null && localProv.selectedLocal!.id == widget.localId)
        ? localProv.selectedLocal
        : (widget.initialLocal != null && widget.initialLocal!.id == widget.localId)
            ? widget.initialLocal
            : localProv.locales.cast<LocalModel?>().firstWhere(
                (l) => l?.id == widget.localId,
                orElse: () => null,
              );

    // 2. Si no existe en memoria ni cache, mostrar skeleton nativo y sutil (sin parpadeos de mascota)
    if (maybeLocal == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
        ),
      );
    }

    final local = maybeLocal;

    final isFav = localProv.favoriteIds.contains(local.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : Colors.white,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    localProv.toggleFavorite(local.id);
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (local.fullPortadaUrl.isNotEmpty)
                      Image.network(
                        local.fullPortadaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.primary),
                      )
                    else
                      Container(color: AppColors.primary),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: local.fullLogoUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(local.fullLogoUrl, fit: BoxFit.cover),
                                  )
                                : Center(child: Text(local.categoriaIcono, style: const TextStyle(fontSize: 28))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  local.nombre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    StarRatingDisplay(
                                      rating: local.calificacionPromedio,
                                      totalReviews: local.totalResenas,
                                      starSize: 15,
                                      showNumber: true,
                                      textColor: Colors.white,
                                      countColor: const Color(0xFFFDE68A),
                                      asBadge: true,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '• ${local.categoriaNombre}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(color: Colors.black54, blurRadius: 4),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: theme.cardColor,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusRow(local, isDark),
                    const SizedBox(height: 12),
                    _buildQuickActions(local, isDark),
                    const SizedBox(height: 12),
                    _buildInfoBlock(local, isDark),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: isDark ? AppColors.accentBlue : AppColors.primary,
                  unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  indicatorColor: isDark ? AppColors.accentBlue : AppColors.primary,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: '🍲 Menú (${menuProv.localDishes.length})'),
                    Tab(text: '🔥 Ofertas (${promoProv.localPromotions.length})'),
                    Tab(text: '⭐ Reseñas (${localProv.selectedLocalResenas.length})'),
                  ],
                ),
                backgroundColor: theme.cardColor,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // 1. Pestaña de Menú
            _buildMenuTab(menuProv),

            // 2. Pestaña de Promociones del local
            _buildPromotionsTab(promoProv),

            // 3. Pestaña de Reseñas
            _buildReviewsTab(localProv),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.rate_review_rounded, color: Colors.white),
        label: const Text('Calificar Local', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showAddReviewDialog,
      ),
    );
  }

  /// Estado de apertura, horario y distancia en una sola línea.
  Widget _buildStatusRow(LocalModel local, bool isDark) {
    final secundario = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final color = local.estaAbierto ? AppColors.success : AppColors.error;
    final horario = local.horarioApertura;

    return Wrap(
      spacing: 10,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            local.estaAbierto ? '● Abierto ahora' : '● Cerrado',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        if (horario != null && horario.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: secundario),
              const SizedBox(width: 4),
              Text(horario, style: TextStyle(fontSize: 12.5, color: secundario)),
            ],
          ),
        if (local.distanciaEnMetros != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.near_me_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '${local.formattedDistance} · ${local.formattedWalkingTime}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.accentBlue : AppColors.primary,
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Acciones de decisión rápida: cómo llegar, WhatsApp y llamar.
  Widget _buildQuickActions(LocalModel local, bool isDark) {
    final tieneWhatsApp = local.whatsApp != null && local.whatsApp!.isNotEmpty;
    final tieneTelefono = local.telefonoContacto != null && local.telefonoContacto!.isNotEmpty;
    final acento = isDark ? AppColors.accentBlue : AppColors.primary;

    final botones = <Widget>[
      Expanded(
        child: FilledButton.icon(
          icon: const Icon(Icons.directions_rounded, size: 18),
          label: const Text('Ruta'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final loc = context.read<LocationProvider>();
            _showRouteModal(
              context,
              local,
              loc.currentPosition?.latitude ?? loc.referenceLatitude,
              loc.currentPosition?.longitude ?? loc.referenceLongitude,
            );
          },
        ),
      ),
      if (tieneWhatsApp)
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _openWhatsApp(local.whatsApp!, local.nombre),
          ),
        ),
      if (tieneTelefono)
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.phone_outlined, size: 18),
            label: const Text('Llamar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: acento,
              side: BorderSide(color: acento, width: 1.2),
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _openPhoneCall(local.telefonoContacto!),
          ),
        ),
    ];

    return Row(
      children: [
        for (var i = 0; i < botones.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          botones[i],
        ],
      ],
    );
  }

  /// Dirección y descripción compactas; la descripción se expande bajo demanda.
  Widget _buildInfoBlock(LocalModel local, bool isDark) {
    final secundario = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final direccion = '${local.direccion}${local.referencia != null ? ' (${local.referencia})' : ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                direccion,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        if (local.descripcion.isNotEmpty) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _descripcionExpandida = !_descripcionExpandida),
            child: Text(
              local.descripcion,
              maxLines: _descripcionExpandida ? null : 2,
              overflow: _descripcionExpandida ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.5, color: secundario, height: 1.4),
            ),
          ),
          if (local.descripcion.length > 90)
            GestureDetector(
              onTap: () => setState(() => _descripcionExpandida = !_descripcionExpandida),
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _descripcionExpandida ? 'Ver menos' : 'Ver más',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.accentBlue : AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildMenuTab(MenuProvider menu) {
    if (menu.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (menu.localDishes.isEmpty) {
      return const Center(child: Text('No hay platos registrados en el menú todavía.'));
    }

    final delDia = menu.platosDelDia;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (delDia.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              '⭐ Platos del Día',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
          ...delDia.map((plato) => DishCard(plato: plato)),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Todo el menú',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
        ],
        ...menu.localDishes.map((plato) => DishCard(plato: plato)),
      ],
    );
  }

  Widget _buildPromotionsTab(PromocionProvider promo) {
    if (promo.localPromotions.isEmpty) {
      return const Center(child: Text('Este local no cuenta con promociones activas actualmente.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: promo.localPromotions.length,
      itemBuilder: (context, index) {
        final p = promo.localPromotions[index];
        return PromotionCard(
          promocion: p,
          onTap: () {},
        );
      },
    );
  }

  Widget _buildReviewsTab(LocalProvider localProv) {
    if (localProv.isLoadingResenas) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (localProv.selectedLocalResenas.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PuniMascot(
                mood: PuniMood.shy,
                size: 110,
                shadow: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Aún no hay reseñas',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                '¡Sé el primer estudiante en calificar este local y compartir tu experiencia!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showAddReviewDialog,
                icon: const Icon(Icons.star_rounded, size: 18),
                label: const Text('Escribir primera reseña'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: localProv.selectedLocalResenas.length,
      itemBuilder: (context, index) {
        final r = localProv.selectedLocalResenas[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          r.estudianteNombre.isNotEmpty ? r.estudianteNombre[0].toUpperCase() : 'U',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        r.estudianteNombre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    r.formattedFecha,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (starIdx) {
                  return Icon(
                    starIdx < r.calificacion ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 16,
                    color: AppColors.accent,
                  );
                }),
              ),
              if (r.comentario != null && r.comentario!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '“${r.comentario!}”',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;

  _SliverAppBarDelegate(this._tabBar, {this.backgroundColor = Colors.white});

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor || oldDelegate._tabBar != _tabBar;
}

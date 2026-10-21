class AppConstants {
  static const String appName = 'UTA Gastronomía';
  static const String appSlogan = 'Encuentra dónde comer cerca de tu campus';

  // Coordenadas oficiales de los campus de la UTA (Ambato, Ecuador)
  static const double utaHuachiLat = -1.2694;
  static const double utaHuachiLng = -78.6253;

  static const double utaIngahurcoLat = -1.2396;
  static const double utaIngahurcoLng = -78.6186;

  static const double utaQuerochacaLat = -1.3411;
  static const double utaQuerochacaLng = -78.6014;

  // Mapa de nombres de campus
  static const Map<int, String> campusNames = {
    1: 'Campus Huachi',
    2: 'Campus Ingahurco',
    3: 'Campus Querochaca',
  };

  // Categorías de Local (Domain.Enums.CategoriaLocal)
  static const Map<int, String> categoriasLocal = {
    1: 'Almuerzos',
    2: 'Comida Rápida',
    3: 'Cafetería',
    4: 'Pizzería',
    5: 'Panadería',
    6: 'Mariscos',
    7: 'Asadero',
    8: 'Vegetariano / Vegano',
    99: 'Otro',
  };

  // Iconos representativos para las categorías
  static const Map<int, String> categoriaIconos = {
    1: '🍲',
    2: '🍔',
    3: '☕',
    4: '🍕',
    5: '🥐',
    6: '🐟',
    7: '🥩',
    8: '🥗',
    99: '🍽️',
  };

  // Categorías de Plato (Domain.Enums.CategoriaPlato)
  static const Map<int, String> categoriasPlato = {
    1: 'Almuerzo',
    2: 'Desayuno',
    3: 'Plato a la Carta',
    4: 'Comida Rápida',
    5: 'Bebida',
    6: 'Postre',
    7: 'Snack',
    8: 'Combo',
    99: 'Otro',
  };

  // Tipos de Eventos de Estadísticas (Domain.Enums.TipoEventoEstadistica)
  static const int eventoVisitaPerfil = 1;
  static const int eventoMenuGuardado = 2;
  static const int eventoClicPromocion = 3;
  static const int eventoClicContactoWhatsApp = 4;
  static const int eventoClicComoLlegar = 5;
}

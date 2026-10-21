import 'package:flutter/material.dart';

/// Paleta Oficial UTA Gastronomía extraída directamente del Frontend Web (app.css)
class AppColors {
  // Azul UTA & Navy
  static const Color primary = Color(0xFF004B87);        // --uta-blue-primary: #004b87
  static const Color primaryDark = Color(0xFF00223E);    // --uta-navy: #00223e
  static const Color navyDark = Color(0xFF001F38);       // --uta-navy-dark: #001f38
  static const Color blueMedium = Color(0xFF003865);     // --uta-blue: #003865
  static const Color primaryVibrant = Color(0xFF0284C7); // --uta-blue-vibrant: #0284c7
  static const Color primaryLight = Color(0xFFE0F2FE);   // --uta-blue-light: #e0f2fe
  static const Color primarySubtle = Color(0xFFF0F9FF);  // --uta-blue-subtle: #f0f9ff

  // Blanco y Superficies (Modo Claro)
  static const Color white = Color(0xFFFFFFFF);          // --pure-white: #ffffff
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);     // --bg-surface: #f8fafc
  static const Color cardBg = Color(0xFFFFFFFF);         // --card-bg: #ffffff
  static const Color border = Color(0xFFE2E8F0);         // --border-color: #e2e8f0
  static const Color borderDarker = Color(0xFFCBD5E1);   // --border-darker: #cbd5e1

  // Superficies Dark Mode (Modo Oscuro)
  static const Color darkBackground = Color(0xFF0B132B); // Fondo profundo
  static const Color darkSurface = Color(0xFF131D38);    // Tarjetas y modales
  static const Color darkCard = Color(0xFF182649);       // Cards elevados
  static const Color darkBorder = Color(0xFF1E2F5A);     // Bordes sutiles oscuros
  static const Color darkTextPrimary = Color(0xFFF1F5F9);// Texto blanco suave
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Texto secundario suave
  static const Color darkPrimaryLight = Color(0xFF1E3A8A);  // Acentos oscuros

  // Tipografía de Alto Contraste
  static const Color textPrimary = Color(0xFF0F172A);    // --text-heading: #0f172a
  static const Color textBody = Color(0xFF1E293B);       // --text-body: #1e293b
  static const Color textSecondary = Color(0xFF64748B);  // --text-muted: #64748b
  static const Color textMuted = Color(0xFF94A3B8);

  // Estados Funcionales
  static const Color accent = Color(0xFFD97706);         // --amber-main: #d97706 (Estrellas / Calificación)
  static const Color accentBlue = Color(0xFF38BDF8);     // Azul cielo para textos/iconos en Dark Mode
  static const Color success = Color(0xFF059669);        // --emerald-main: #059669 (Abierto / Aprobado)
  static const Color error = Color(0xFFDC2626);          // --rose-main: #dc2626 (Cerrado / Error)

  // Chips y Fills
  static const Color chipBackground = Color(0xFFF1F5F9); // --slate-bg: #f1f5f9
}

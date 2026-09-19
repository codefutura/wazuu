import 'package:flutter/material.dart';

/// Paleta de colores de Wazuu (ver sección 3 de CLAUDE.md).
///
/// El teal primario y el sistema semántico verde/ámbar/coral son fijos:
/// no cambian entre tema claro y oscuro.
abstract final class AppColors {
  // Marca
  static const teal = Color(0xFF0F766E);
  static const mintLight = Color(0xFFCCFBF1);

  // Semánticos (idénticos en ambos temas) — para rellenos, badges y
  // barras de progreso.
  static const coral = Color(0xFFFB7185);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);

  // Variantes más oscuras de los mismos semánticos, para texto/íconos
  // sobre fondo claro — los tonos de arriba no llegan a 4.5:1 de
  // contraste AA sobre blanco (ver auditoría de la Fase 9). Mismo tono
  // reconocible, ajustado solo para legibilidad como primer plano.
  static const coralOnLight = Color(0xFFE11D48);
  static const successOnLight = Color(0xFF15803D);
  static const warningOnLight = Color(0xFFB45309);

  /// Amarillo suave (misma familia que `warning`, más claro) para texto
  /// secundario sobre el fondo teal — el ámbar vivo pierde legibilidad
  /// ahí cuando se usa como color de texto completo en vez de acento.
  static const warningSoft = Color(0xFFFDE68A);

  // Tema claro
  static const lightBackground = Color(0xFFFFF7ED);
  static const lightTextPrimary = Color(0xFF1E293B);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightSurface = Colors.white;

  // Tema oscuro
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);

  /// Color de texto/ícono para el estado "éxito" — usa la variante
  /// oscura en tema claro (contraste AA), el semántico normal en
  /// oscuro (ya cumple ahí).
  static Color successText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? successOnLight
      : success;

  static Color warningText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? warningOnLight
      : warning;

  static Color coralText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? coralOnLight : coral;
}

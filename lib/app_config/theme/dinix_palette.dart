import 'package:flutter/material.dart';

class DinixPalette {
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textMuted;
  final Color onPrimary;

  const DinixPalette({
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textMuted,
    required this.onPrimary,
  });

  static const dark = DinixPalette(
    primary: Color(0xFFFF9800),
    primaryDark: Color(0xFF000000),
    secondary: Color(0xFFFF9800),
    background: Color(0xFF121212),
    surface: Color(0xFF121212),
    surfaceElevated: Color(0xFF1C1C1C),
    textPrimary: Color(0xFFF5F5F5),
    textMuted: Color(0xFFBDBDBD),
    onPrimary: Color(0xFF000000),
  );

  static const light = DinixPalette(
    primary: Color(0xFF0D47A1),
    // Barras (topo/baixo) = mesmo cinza dos cards, para destacar do fundo.
    primaryDark: Color(0xFFF0F0F0),
    secondary: Color(0xFF0D47A1),
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF0F0F0),
    textPrimary: Color(0xFF212121),
    // Cinza legível sobre cards claros (evita grey400 do pacote, feito para fundo escuro).
    textMuted: Color(0xFF5F6368),
    onPrimary: Color(0xFFFFFFFF),
  );
}
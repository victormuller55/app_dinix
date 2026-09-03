import 'package:flutter/material.dart';

class DinixPalette {
  final Color primary;
  final Color secondary;

  /// Fundo da barra inferior (e da navigation bar do sistema).
  final Color primaryDark;

  /// Fundo da AppBar e da status bar.
  final Color appBar;

  /// Fundo do drawer: um tom abaixo das barras.
  final Color drawer;

  /// Título e ícone de voltar sobre as barras.
  final Color onAppBar;

  /// Ícones de ação da AppBar e item ativo da barra inferior.
  final Color appBarIcon;

  /// Item inativo da barra inferior.
  final Color onAppBarMuted;

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
    required this.appBar,
    required this.drawer,
    required this.onAppBar,
    required this.appBarIcon,
    required this.onAppBarMuted,
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
    appBar: Color(0xFF000000),
    drawer: Color(0xFF000000),
    onAppBar: Color(0xFFF5F5F5),
    appBarIcon: Color(0xFFFF9800),
    onAppBarMuted: Color(0xFFBDBDBD),
    background: Color(0xFF121212),
    surface: Color(0xFF121212),
    surfaceElevated: Color(0xFF1C1C1C),
    textPrimary: Color(0xFFF5F5F5),
    textMuted: Color(0xFFBDBDBD),
    onPrimary: Color(0xFF000000),
  );

  static const light = DinixPalette(
    // Grafite azulado no lugar do laranja: acentos e barras na mesma cor.
    primary: Color(0xFF1F2937),
    secondary: Color(0xFF1F2937),
    primaryDark: Color(0xFF1F2937),
    appBar: Color(0xFF1F2937),
    drawer: Color(0xFF111827),
    onAppBar: Color(0xFFFFFFFF),
    // Sobre as barras a cor de acento sumiria: o conteúdo delas é branco.
    appBarIcon: Color(0xFFFFFFFF),
    onAppBarMuted: Color(0x99FFFFFF),
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF0F0F0),
    textPrimary: Color(0xFF212121),
    // Cinza legível sobre cards claros (evita grey400 do pacote, feito para fundo escuro).
    textMuted: Color(0xFF5F6368),
    onPrimary: Color(0xFFFFFFFF),
  );
}

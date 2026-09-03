import 'package:app_dinix/app_config/theme/dinix_palette.dart';
import 'package:flutter/material.dart';

/// Cores da marca Dinix (camada 2). Neutros vêm de `AppColors` do pacote.
///
/// Os valores mudam conforme o tema claro/escuro aplicado em [apply].
class DinixColors {
  DinixColors._();

  static DinixPalette _palette = DinixPalette.dark;

  static DinixPalette get palette => _palette;

  static void apply(DinixPalette palette) {
    _palette = palette;
  }

  static void applyBrightness(Brightness brightness) {
    _palette =
        brightness == Brightness.dark ? DinixPalette.dark : DinixPalette.light;
  }

  static Color get primary => _palette.primary;
  static Color get primaryDark => _palette.primaryDark;
  static Color get secondary => _palette.secondary;
  static Color get appBar => _palette.appBar;
  static Color get drawer => _palette.drawer;
  static Color get onAppBar => _palette.onAppBar;
  static Color get appBarIcon => _palette.appBarIcon;
  static Color get onAppBarMuted => _palette.onAppBarMuted;
  static Color get background => _palette.background;
  static Color get surface => _palette.surface;
  static Color get surfaceElevated => _palette.surfaceElevated;
  static Color get textPrimary => _palette.textPrimary;
  static Color get textMuted => _palette.textMuted;
  static Color get onPrimary => _palette.onPrimary;
}

import 'package:app_dinix/app_config/theme/dinix_palette.dart';
import 'package:app_dinix/app_config/const/dinix_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'theme_mode';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  ThemeMode _mode = ThemeMode.dark;
  bool _ready = false;
  int _generation = 0;

  ThemeMode get mode => _mode;
  bool get ready => _ready;
  int get generation => _generation;

  String get modeLabel {
    switch (_mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  /// Sempre inicia no escuro. Tema claro/sistema vale só na sessão atual.
  Future<void> load() async {
    _mode = ThemeMode.dark;
    DinixColors.apply(DinixPalette.dark);
    _ready = true;
    notifyListeners();

    // Remove preferência antiga para não restaurar o modo claro.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    _generation++;
    // Aplica já a paleta nos modos fixos; no system o builder resolve.
    if (mode == ThemeMode.light) {
      DinixColors.apply(DinixPalette.light);
    } else if (mode == ThemeMode.dark) {
      DinixColors.apply(DinixPalette.dark);
    }
    notifyListeners();
  }

  DinixPalette paletteFor(Brightness brightness) {
    return brightness == Brightness.dark ? DinixPalette.dark : DinixPalette.light;
  }

  Brightness resolveBrightness(Brightness platformBrightness) {
    switch (_mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return platformBrightness;
    }
  }
}

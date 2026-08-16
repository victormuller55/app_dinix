import 'package:flutter/material.dart';

/// Faz as telas que usam [DinixColors] reconstruírem ao trocar o tema.
class DinixThemeScope extends InheritedWidget {
  const DinixThemeScope({
    super.key,
    required this.generation,
    required this.brightness,
    required super.child,
  });

  final int generation;
  final Brightness brightness;

  static DinixThemeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DinixThemeScope>();
  }

  /// Registra dependência do tema (chame no build de scaffolds/páginas raiz).
  static void depend(BuildContext context) {
    maybeOf(context);
  }

  @override
  bool updateShouldNotify(DinixThemeScope oldWidget) {
    return generation != oldWidget.generation ||
        brightness != oldWidget.brightness;
  }
}

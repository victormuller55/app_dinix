import 'package:flutter/material.dart';

/// Fecha o teclado e remove o foco do campo atual.
void fecharTeclado() {
  FocusManager.instance.primaryFocus?.unfocus();
}

/// Fecha o teclado ao entrar/sair de rotas (push, pop, replace).
class FecharTecladoNavigatorObserver extends NavigatorObserver {
  void _fechar() {
    // Após o frame evita conflito com a transição da rota.
    WidgetsBinding.instance.addPostFrameCallback((_) => fecharTeclado());
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _fechar();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _fechar();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _fechar();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _fechar();
}

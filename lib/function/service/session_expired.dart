import 'dart:convert';

import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/pages/login_page/entrar_page.dart';

const _mensagemSessaoExpirada =
    'Sua sessão expirou. Faça login novamente para continuar.';

bool _tratandoSessao = false;

bool isSessaoExpirada(Object e) {
  if (e is! ApiException) return false;

  final status = e.response.statusCode;
  if (status != 401) return false;

  final bodyRaw = e.response.body.toString();
  final body = bodyRaw.toLowerCase();

  if (body.contains('nao_autorizado') ||
      body.contains('não_autorizado') ||
      body.contains('token_invalido') ||
      body.contains('unauthorized')) {
    return true;
  }

  try {
    final map = jsonDecode(e.response.body) as Map<String, dynamic>;
    final erro = (map['erro'] ?? map['error'] ?? '').toString().toLowerCase();
    return erro.contains('nao_autorizado') ||
        erro.contains('token_invalido') ||
        erro.contains('não_autorizado');
  } catch (_) {
    return true;
  }
}

/// Limpa a sessão, volta ao login e avisa o usuário.
/// Retorna `true` se tratou a sessão expirada.
Future<bool> tratarSessaoExpirada(Object e) async {
  if (!isSessaoExpirada(e)) return false;
  if (_tratandoSessao) return true;

  _tratandoSessao = true;
  try {
    await clearToken();
    showToastWarning(message: _mensagemSessaoExpirada);
    open(screen: const LoginPage(), closePrevious: true);
  } finally {
    Future.delayed(const Duration(seconds: 2), () {
      _tratandoSessao = false;
    });
  }
  return true;
}

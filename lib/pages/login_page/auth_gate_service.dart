import 'dart:convert';

import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/models/usuario_model.dart';
import 'package:app_dinix/services/usuario_service.dart';

Future<bool> verificarSessaoAuthGate() async {
  if (!await hasSessaoValida()) return false;

  try {
    final response = await getUsuarioEu();
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final usuario = UsuarioModel.fromMap(map);
    final atual = await getUsuarioLogado();
    usuario.token = atual?.token ?? usuario.token;
    usuario.tipoToken = atual?.tipoToken ?? usuario.tipoToken;
    usuario.expiraEm = atual?.expiraEm ?? usuario.expiraEm;
    await saveUsuarioLogado(usuario);
    return true;
  } catch (e) {
    if (isSessaoExpirada(e)) {
      await clearToken();
      return false;
    }
    return true;
  }
}

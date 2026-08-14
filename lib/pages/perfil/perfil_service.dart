import 'dart:convert';

import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/models/usuario_model.dart';
import 'package:app_dinix/services/usuario_service.dart';

Future<UsuarioModel> carregarPerfil() async {
  final local = await getUsuarioLogado();
  try {
    final response = await getUsuarioEu();
    final usuario = UsuarioModel.fromMap(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
    usuario.token = local?.token ?? usuario.token;
    usuario.tipoToken = local?.tipoToken ?? usuario.tipoToken;
    usuario.expiraEm = local?.expiraEm ?? usuario.expiraEm;
    await saveUsuarioLogado(usuario);
    return usuario;
  } catch (_) {
    if (local != null) return local;
    rethrow;
  }
}

Future<void> sairDaConta() async {
  await clearToken();
}

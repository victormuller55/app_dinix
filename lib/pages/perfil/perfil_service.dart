import 'dart:convert';

import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/models/usuario_model.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/verificacao_email_service.dart';
import 'package:app_dinix/services/usuario_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muller_package/muller_package.dart';

Future<UsuarioModel> carregarPerfil() async {
  final local = await getUsuarioLogado();
  try {
    final response = await getUsuarioEu();
    return _persistirUsuario(response, local: local);
  } catch (_) {
    if (local != null) return local;
    rethrow;
  }
}

Future<UsuarioModel> atualizarNomePerfil(String nome) async {
  final local = await getUsuarioLogado();
  final response = await patchUsuarioEu(nome: nome.trim());
  return _persistirUsuario(response, local: local);
}

Future<void> trocarSenhaPerfil({
  required String senhaAtual,
  required String senhaNova,
}) async {
  await putUsuarioSenha(senhaAtual: senhaAtual, senhaNova: senhaNova);
}

Future<void> enviarCodigoNovoEmail(String email) {
  return enviarCodigoVerificacaoEmail(email: email);
}

Future<UsuarioModel> trocarEmailPerfil({
  required String email,
  required String codigo,
}) async {
  final response = await putUsuarioEmail(email: email.trim(), codigo: codigo.trim());
  return _persistirAuth(response);
}

Future<UsuarioModel> atualizarFotoPerfil(XFile foto) async {
  final local = await getUsuarioLogado();
  final response = await putUsuarioFoto(foto);
  return _persistirUsuario(response, local: local);
}

Future<UsuarioModel> removerFotoPerfil() async {
  final local = await getUsuarioLogado();
  final response = await deleteUsuarioFoto();
  return _persistirUsuario(response, local: local);
}

Future<void> apagarContaPerfil({required String senha}) async {
  await postUsuarioExcluir(senha: senha);
  await clearToken();
}

Future<void> sairDaConta() async {
  await clearToken();
}

UsuarioModel _usuarioDe(AppResponse response) {
  return UsuarioModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<UsuarioModel> _persistirUsuario(AppResponse response, {UsuarioModel? local}) async {
  final usuario = _usuarioDe(response);
  usuario.token = local?.token ?? usuario.token;
  usuario.tipoToken = local?.tipoToken ?? usuario.tipoToken;
  usuario.expiraEm = local?.expiraEm ?? usuario.expiraEm;
  await saveUsuarioLogado(usuario);
  return usuario;
}

Future<UsuarioModel> _persistirAuth(AppResponse response) async {
  final usuario = _usuarioDe(response);
  final token = usuario.token;
  if (token != null && token.isNotEmpty) {
    await saveToken(token);
  }
  await saveUsuarioLogado(usuario);
  return usuario;
}

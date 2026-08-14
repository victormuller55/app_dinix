import 'dart:convert';

import 'package:app_dinix/models/usuario_model.dart';
import 'package:app_dinix/services/auth_service.dart';

Future<UsuarioModel> registrarUsuario({
  required String nome,
  required String email,
  required String senha,
}) async {
  final response = await postAuthRegistrar(
    nome: nome,
    email: email,
    senha: senha,
  );
  final map = jsonDecode(response.body) as Map<String, dynamic>;
  return UsuarioModel.fromMap(map);
}

import 'dart:convert';

import 'package:app_dinix/services/auth_service.dart';

Future<void> enviarCodigoVerificacaoEmail({required String email}) async {
  await postAuthEnviarCodigoEmail(email: email.trim());
}

Future<bool> verificarCodigoEmail({
  required String email,
  required String codigo,
}) async {
  final response = await postAuthVerificarEmail(
    email: email.trim(),
    codigo: codigo.trim(),
  );
  final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  return map['verificado'] == true;
}

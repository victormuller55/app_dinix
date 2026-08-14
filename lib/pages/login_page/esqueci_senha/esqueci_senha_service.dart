import 'package:app_dinix/services/auth_service.dart';

Future<void> enviarCodigoEsqueciSenha({required String email}) async {
  await postAuthEsqueciSenhaEnviarCodigo(email: email.trim());
}

Future<void> redefinirSenhaComCodigo({
  required String email,
  required String codigo,
  required String senha,
}) async {
  await postAuthEsqueciSenhaRedefinir(
    email: email.trim(),
    codigo: codigo.trim(),
    senha: senha,
  );
}

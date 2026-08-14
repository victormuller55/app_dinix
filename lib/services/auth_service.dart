import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';

Future<AppResponse> postAuthEntrar({
  required String email,
  required String senha,
}) {
  return postJson(
    endpoint: AppEndpoints.endpointAuthEntrar,
    body: {
      'email': email,
      'senha': senha,
    },
  );
}

Future<AppResponse> postAuthRegistrar({
  required String nome,
  required String email,
  required String senha,
}) {
  return postJson(
    endpoint: AppEndpoints.endpointAuthRegistrar,
    body: {
      'nome': nome,
      'email': email,
      'senha': senha,
    },
  );
}

Future<AppResponse> postAuthEnviarCodigoEmail({required String email}) {
  return postJson(
    endpoint: AppEndpoints.endpointAuthEnviarCodigoEmail,
    body: {'email': email},
  );
}

Future<AppResponse> postAuthVerificarEmail({
  required String email,
  required String codigo,
}) {
  return postJson(
    endpoint: AppEndpoints.endpointAuthVerificarEmail,
    body: {
      'email': email,
      'codigo': codigo,
    },
  );
}

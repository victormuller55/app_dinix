import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';
import 'package:image_picker/image_picker.dart';

Future<AppResponse> getUsuarioEu() {
  return getJson(endpoint: AppEndpoints.endpointUsuariosEu);
}

Future<AppResponse> patchUsuarioEu({required String nome}) {
  return patchJson(
    endpoint: AppEndpoints.endpointUsuariosEu,
    body: {'nome': nome},
  );
}

Future<AppResponse> putUsuarioSenha({
  required String senhaAtual,
  required String senhaNova,
}) {
  return putJson(
    endpoint: AppEndpoints.endpointUsuariosEuSenha,
    body: {
      'senha_atual': senhaAtual,
      'senha_nova': senhaNova,
    },
  );
}

Future<AppResponse> putUsuarioEmail({
  required String email,
  required String codigo,
}) {
  return putJson(
    endpoint: AppEndpoints.endpointUsuariosEuEmail,
    body: {
      'email': email,
      'codigo': codigo,
    },
  );
}

Future<AppResponse> postUsuarioExcluir({required String senha}) {
  return postJson(
    endpoint: AppEndpoints.endpointUsuariosEuExcluir,
    body: {'senha': senha},
  );
}

Future<AppResponse> putUsuarioFoto(XFile foto) {
  return putMultipartFoto(
    endpoint: AppEndpoints.endpointUsuariosEuFoto,
    foto: foto,
  );
}

Future<AppResponse> deleteUsuarioFoto() {
  return deleteAndReadJson(endpoint: AppEndpoints.endpointUsuariosEuFoto);
}

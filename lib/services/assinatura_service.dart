import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';

Future<AppResponse> getAssinaturas({int numPag = 1, int itensPag = 20}) {
  return getJson(
    endpoint: AppEndpoints.endpointAssinaturas,
    parameters: {
      'num_pag': numPag.toString(),
      'itens_pag': itensPag.toString(),
    },
  );
}

Future<AppResponse> postAssinatura(Map<String, dynamic> body) {
  return postJson(endpoint: AppEndpoints.endpointAssinaturas, body: body);
}

Future<AppResponse> putAssinatura(String id, Map<String, dynamic> body) {
  return putJson(endpoint: AppEndpoints.endpointAssinaturasPorId(id), body: body);
}

Future<void> deleteAssinatura(String id) {
  return deleteJson(endpoint: AppEndpoints.endpointAssinaturasPorId(id));
}

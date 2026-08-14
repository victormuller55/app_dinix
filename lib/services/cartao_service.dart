import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';

Future<AppResponse> getCartoes({int numPag = 1, int itensPag = 20}) {
  return getJson(
    endpoint: AppEndpoints.endpointCartoes,
    parameters: {
      'num_pag': numPag.toString(),
      'itens_pag': itensPag.toString(),
    },
  );
}

Future<AppResponse> getCartaoPorId(String id) {
  return getJson(endpoint: AppEndpoints.endpointCartoesPorId(id));
}

Future<AppResponse> postCartao(Map<String, dynamic> body) {
  return postJson(endpoint: AppEndpoints.endpointCartoes, body: body);
}

Future<AppResponse> putCartao(String id, Map<String, dynamic> body) {
  return putJson(endpoint: AppEndpoints.endpointCartoesPorId(id), body: body);
}

Future<void> deleteCartao(String id) {
  return deleteJson(endpoint: AppEndpoints.endpointCartoesPorId(id));
}

import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';

Future<AppResponse> getContas({int numPag = 1, int itensPag = 20}) {
  return getJson(
    endpoint: AppEndpoints.endpointContas,
    parameters: {
      'num_pag': numPag.toString(),
      'itens_pag': itensPag.toString(),
    },
  );
}

Future<AppResponse> getContaPorId(String id) {
  return getJson(endpoint: AppEndpoints.endpointContasPorId(id));
}

Future<AppResponse> postConta(Map<String, dynamic> body) {
  return postJson(endpoint: AppEndpoints.endpointContas, body: body);
}

Future<AppResponse> putConta(String id, Map<String, dynamic> body) {
  return putJson(endpoint: AppEndpoints.endpointContasPorId(id), body: body);
}

Future<void> deleteConta(String id) {
  return deleteJson(endpoint: AppEndpoints.endpointContasPorId(id));
}

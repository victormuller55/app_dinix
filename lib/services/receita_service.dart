import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';
import 'package:muller_package/muller_package.dart';

Future<AppResponse> getReceitas({int numPag = 1, int itensPag = 20}) {
  return getJson(
    endpoint: AppEndpoints.endpointReceitas,
    parameters: {
      'num_pag': numPag.toString(),
      'itens_pag': itensPag.toString(),
    },
  );
}

Future<AppResponse> postReceita(Map<String, dynamic> body) {
  return postJson(endpoint: AppEndpoints.endpointReceitas, body: body);
}

Future<AppResponse> putReceita(String id, Map<String, dynamic> body) {
  return putJson(endpoint: AppEndpoints.endpointReceitasPorId(id), body: body);
}

Future<void> deleteReceita(String id) {
  return deleteJson(endpoint: AppEndpoints.endpointReceitasPorId(id));
}

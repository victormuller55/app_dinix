import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';

Future<AppResponse> getLocais({int numPag = 1, int itensPag = 20}) {
  return getJson(
    endpoint: AppEndpoints.endpointLocais,
    parameters: {
      'num_pag': numPag.toString(),
      'itens_pag': itensPag.toString(),
    },
  );
}

Future<AppResponse> postLocal(Map<String, dynamic> body) {
  return postJson(endpoint: AppEndpoints.endpointLocais, body: body);
}

Future<AppResponse> putLocal(String id, Map<String, dynamic> body) {
  return putJson(endpoint: AppEndpoints.endpointLocaisPorId(id), body: body);
}

Future<void> deleteLocal(String id) {
  return deleteJson(endpoint: AppEndpoints.endpointLocaisPorId(id));
}

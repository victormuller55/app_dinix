import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';

Future<AppResponse> getCompras({
  int numPag = 1,
  int itensPag = 20,
  int? mes,
  int? ano,
  List<String>? dias,
}) {
  return getJson(
    endpoint: AppEndpoints.endpointCompras,
    parameters: {
      'num_pag': numPag.toString(),
      'itens_pag': itensPag.toString(),
      if (mes != null) 'mes': mes.toString(),
      if (ano != null) 'ano': ano.toString(),
      if (dias != null && dias.isNotEmpty) 'dias': dias.join(','),
    },
  );
}

Future<AppResponse> postCompra(Map<String, dynamic> body) {
  return postJson(endpoint: AppEndpoints.endpointCompras, body: body);
}

Future<AppResponse> putCompra(String id, Map<String, dynamic> body) {
  return putJson(endpoint: AppEndpoints.endpointComprasPorId(id), body: body);
}

Future<void> deleteCompra(String id) {
  return deleteJson(endpoint: AppEndpoints.endpointComprasPorId(id));
}

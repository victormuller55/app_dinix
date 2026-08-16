import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';
import 'package:muller_package/muller_package.dart';

Future<AppResponse> getPatrimonio() {
  return getJson(endpoint: AppEndpoints.endpointPatrimonio);
}

Future<AppResponse> getPatrimonioHistorico({
  int numPag = 1,
  int itensPag = 12,
}) {
  return getJson(
    endpoint: AppEndpoints.endpointPatrimonioHistorico,
    parameters: {
      'num_pag': numPag.toString(),
      'itens_pag': itensPag.toString(),
    },
  );
}

Future<AppResponse> getAssinaturasResumo() {
  return getJson(endpoint: AppEndpoints.endpointAssinaturasResumo);
}

Future<AppResponse> getPrevisao({int? mes, int? ano}) {
  final params = <String, String>{};
  if (mes != null) params['mes'] = mes.toString();
  if (ano != null) params['ano'] = ano.toString();
  return getJson(
    endpoint: AppEndpoints.endpointPrevisao,
    parameters: params.isEmpty ? null : params,
  );
}

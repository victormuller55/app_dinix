import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';
import 'package:muller_package/muller_package.dart';

Future<AppResponse> getPainel({int? mes, int? ano}) {
  final params = <String, String>{};
  if (mes != null) params['mes'] = mes.toString();
  if (ano != null) params['ano'] = ano.toString();
  return getJson(
    endpoint: AppEndpoints.endpointPainel,
    parameters: params.isEmpty ? null : params,
  );
}

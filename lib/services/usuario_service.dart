import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';

Future<AppResponse> getUsuarioEu() {
  return getJson(endpoint: AppEndpoints.endpointUsuariosEu);
}

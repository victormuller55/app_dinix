import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';
import 'package:muller_package/muller_package.dart';

Future<AppResponse> getRecebimentosMensais({int numPag = 1, int itensPag = 50}) {
  return getJson(
    endpoint: AppEndpoints.endpointReceitasMensais,
    parameters: {
      'num_pag': numPag.toString(),
      'itens_pag': itensPag.toString(),
    },
  );
}

Future<AppResponse> getRecebimentosMensaisPendentes(String dataIso) {
  return getJson(
    endpoint: AppEndpoints.endpointReceitasMensaisPendentes,
    parameters: {'data': dataIso},
  );
}

Future<AppResponse> postRecebimentoMensal(Map<String, dynamic> body) {
  return postJson(endpoint: AppEndpoints.endpointReceitasMensais, body: body);
}

Future<AppResponse> putRecebimentoMensal(String id, Map<String, dynamic> body) {
  return putJson(
    endpoint: AppEndpoints.endpointReceitasMensaisPorId(id),
    body: body,
  );
}

Future<void> deleteRecebimentoMensal(String id) {
  return deleteJson(endpoint: AppEndpoints.endpointReceitasMensaisPorId(id));
}

Future<AppResponse> receberRecebimentoMensal(
  String id, {
  required String idConta,
  String? dataIso,
}) {
  return postJson(
    endpoint: AppEndpoints.endpointReceitasMensaisReceber(id),
    parameters: {
      if (dataIso != null && dataIso.isNotEmpty) 'data': dataIso,
    },
    body: {'id_conta': idConta},
  );
}

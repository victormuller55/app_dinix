import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';
import 'package:muller_package/muller_package.dart';

Future<AppResponse> getGastosMensais({int numPag = 1, int itensPag = 50}) {
  return getJson(
    endpoint: AppEndpoints.endpointDespesasRecorrentes,
    parameters: {
      'num_pag': numPag.toString(),
      'itens_pag': itensPag.toString(),
    },
  );
}

Future<AppResponse> getGastosMensaisPendentes(String dataIso) {
  return getJson(
    endpoint: AppEndpoints.endpointDespesasRecorrentesPendentes,
    parameters: {'data': dataIso},
  );
}

Future<AppResponse> postGastoMensal(Map<String, dynamic> body) {
  return postJson(endpoint: AppEndpoints.endpointDespesasRecorrentes, body: body);
}

Future<AppResponse> putGastoMensal(String id, Map<String, dynamic> body) {
  return putJson(
    endpoint: AppEndpoints.endpointDespesasRecorrentesPorId(id),
    body: body,
  );
}

Future<void> deleteGastoMensal(String id) {
  return deleteJson(endpoint: AppEndpoints.endpointDespesasRecorrentesPorId(id));
}

Future<AppResponse> pagarGastoMensal(
  String id, {
  required String formaPagamento,
  String? idConta,
  String? idCartaoCredito,
  String? dataIso,
}) {
  return postJson(
    endpoint: AppEndpoints.endpointDespesasRecorrentesPagar(id),
    parameters: {
      if (dataIso != null && dataIso.isNotEmpty) 'data': dataIso,
    },
    body: {
      'forma_pagamento': formaPagamento,
      'id_conta': idConta,
      'id_cartao_credito': idCartaoCredito,
    },
  );
}

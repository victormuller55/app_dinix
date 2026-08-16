import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/http_helper.dart';
import 'package:muller_package/muller_package.dart';

Future<AppResponse> getTransacoesBusca({
  String? busca,
  String? tipo,
  String? idCategoria,
  String? idConta,
  String? idCartaoCredito,
  String? dataInicio,
  String? dataFim,
  double? valorMin,
  double? valorMax,
  bool? alteraSaldoConta,
  int numPag = 1,
  int itensPag = 20,
}) {
  final params = <String, String>{
    'num_pag': numPag.toString(),
    'itens_pag': itensPag.toString(),
  };
  if (busca != null && busca.isNotEmpty) params['busca'] = busca;
  if (tipo != null && tipo.isNotEmpty) params['tipo'] = tipo;
  if (idCategoria != null && idCategoria.isNotEmpty) {
    params['id_categoria'] = idCategoria;
  }
  if (idConta != null && idConta.isNotEmpty) params['id_conta'] = idConta;
  if (idCartaoCredito != null && idCartaoCredito.isNotEmpty) {
    params['id_cartao_credito'] = idCartaoCredito;
  }
  if (dataInicio != null && dataInicio.isNotEmpty) {
    params['data_inicio'] = dataInicio;
  }
  if (dataFim != null && dataFim.isNotEmpty) params['data_fim'] = dataFim;
  if (valorMin != null) params['valor_min'] = valorMin.toStringAsFixed(2);
  if (valorMax != null) params['valor_max'] = valorMax.toStringAsFixed(2);
  if (alteraSaldoConta != null) {
    params['altera_saldo_conta'] = alteraSaldoConta.toString();
  }

  return getJson(
    endpoint: AppEndpoints.endpointTransacoesBusca,
    parameters: params,
  );
}

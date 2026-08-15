import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/function/service/http_helper.dart';
import 'package:app_dinix/models/fatura_cartao_model.dart';
import 'dart:convert';

import 'package:app_dinix/app_config/const/app_endpoints.dart';

List<FaturaCartaoModel> _parseLista(dynamic decoded) {
  final list = decoded is List
      ? decoded
      : (decoded is Map && decoded['itens'] is List)
          ? decoded['itens'] as List
          : const [];
  return list
      .whereType<Map>()
      .map((e) => FaturaCartaoModel.fromMap(Map<String, dynamic>.from(e)))
      .toList();
}

Future<List<FaturaCartaoModel>> listarFaturasCartao(String idCartao) async {
  final response = await getJson(
    endpoint: AppEndpoints.endpointCartoesFaturas(idCartao),
  );
  return _parseLista(jsonDecode(response.body));
}

Future<FaturaCartaoModel> criarFaturaCartao(
  String idCartao,
  FaturaCartaoModel fatura,
) async {
  final response = await postJson(
    endpoint: AppEndpoints.endpointCartoesFaturas(idCartao),
    body: fatura.toJsonCadastro(),
  );
  await _invalidarCachesCartao();
  return FaturaCartaoModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<FaturaCartaoModel> atualizarValorFatura(FaturaCartaoModel fatura) async {
  final id = fatura.id;
  if (id == null || id.isEmpty) {
    throw Exception('Fatura sem id');
  }
  final response = await putJson(
    endpoint: AppEndpoints.endpointCartoesFaturaPorId(id),
    body: fatura.toJsonValor(),
  );
  await _invalidarCachesCartao();
  return FaturaCartaoModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<List<FaturaCartaoModel>> fecharFaturaAtual(String idCartao) async {
  final response = await postJson(
    endpoint: AppEndpoints.endpointCartoesFecharFaturaAtual(idCartao),
    body: const {},
  );
  await _invalidarCachesCartao();
  return _parseLista(jsonDecode(response.body));
}

Future<void> pagarFaturaCartao(String idFatura, {required String idConta}) async {
  await postJson(
    endpoint: AppEndpoints.endpointCartoesFaturaPagar(idFatura),
    body: {'id_conta': idConta},
  );
  await _invalidarCachesCartao();
  await PageDataCache.invalidate(CacheKeys.contas);
}

Future<void> removerFaturaCartao(String idFatura) async {
  await deleteJson(endpoint: AppEndpoints.endpointCartoesFaturaPorId(idFatura));
  await _invalidarCachesCartao();
}

Future<void> _invalidarCachesCartao() async {
  await PageDataCache.invalidate(CacheKeys.cartoes);
  await PageDataCache.invalidate(CacheKeys.painel);
}

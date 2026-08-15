import 'dart:convert';

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/cache/paginated_list_cache.dart';
import 'package:app_dinix/models/gasto_mensal_model.dart';
import 'package:app_dinix/models/paginacao_model.dart';
import 'package:app_dinix/services/gasto_mensal_service.dart';

Future<PaginacaoModel<GastoMensalModel>> listarGastosMensais({
  bool forceRefresh = false,
  int pagina = 1,
}) {
  return PaginatedListCache.load(
    key: CacheKeys.gastosMensais,
    fromMap: GastoMensalModel.fromMap,
    toMap: (e) => e.toMap(),
    forceRefresh: forceRefresh,
    pagina: pagina,
    fetch: () async {
      final response = await getGastosMensais(numPag: pagina);
      final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      return PaginacaoModel.fromMap(map, GastoMensalModel.fromMap);
    },
  );
}

Future<List<GastoMensalModel>> listarGastosMensaisPendentes(DateTime data) async {
  final iso =
      '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  final response = await getGastosMensaisPendentes(iso);
  final decoded = jsonDecode(response.body);
  if (decoded is! List) return [];
  return decoded
      .map((e) => GastoMensalModel.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();
}

Future<void> salvarGastoMensal(GastoMensalModel gasto) async {
  final id = gasto.id;
  if (id != null && id.isNotEmpty) {
    await putGastoMensal(id, gasto.toJsonCadastro());
  } else {
    await postGastoMensal(gasto.toJsonCadastro());
  }
  await PageDataCache.invalidate(CacheKeys.gastosMensais);
  if (gasto.pagamentoHoje == true) {
    await PageDataCache.invalidatePrefix(CacheKeys.compras);
    await PageDataCache.invalidate(CacheKeys.painel);
    await PageDataCache.invalidate(CacheKeys.contas);
    await PageDataCache.invalidate(CacheKeys.cartoes);
  }
}

Future<void> removerGastoMensal(String id) async {
  await deleteGastoMensal(id);
  await PageDataCache.invalidate(CacheKeys.gastosMensais);
}

Future<void> confirmarPagamentoGastoMensal({
  required String id,
  required String formaPagamento,
  String? idConta,
  String? idCartaoCredito,
  String? dataIso,
}) async {
  await pagarGastoMensal(
    id,
    formaPagamento: formaPagamento,
    idConta: idConta,
    idCartaoCredito: idCartaoCredito,
    dataIso: dataIso,
  );
  await PageDataCache.invalidate(CacheKeys.gastosMensais);
  await PageDataCache.invalidatePrefix(CacheKeys.compras);
  await PageDataCache.invalidate(CacheKeys.painel);
  await PageDataCache.invalidate(CacheKeys.contas);
  await PageDataCache.invalidate(CacheKeys.cartoes);
}

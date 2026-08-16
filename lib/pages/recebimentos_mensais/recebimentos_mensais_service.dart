import 'dart:convert';

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/cache/paginated_list_cache.dart';
import 'package:app_dinix/models/paginacao_model.dart';
import 'package:app_dinix/models/recebimento_mensal_model.dart';
import 'package:app_dinix/services/recebimento_mensal_service.dart';

Future<PaginacaoModel<RecebimentoMensalModel>> listarRecebimentosMensais({
  bool forceRefresh = false,
  int pagina = 1,
}) {
  return PaginatedListCache.load(
    key: CacheKeys.recebimentosMensais,
    fromMap: RecebimentoMensalModel.fromMap,
    toMap: (e) => e.toMap(),
    forceRefresh: forceRefresh,
    pagina: pagina,
    fetch: () async {
      final response = await getRecebimentosMensais(numPag: pagina);
      final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      return PaginacaoModel.fromMap(map, RecebimentoMensalModel.fromMap);
    },
  );
}

Future<List<RecebimentoMensalModel>> listarRecebimentosMensaisPendentes(
  DateTime data,
) async {
  final iso =
      '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  final response = await getRecebimentosMensaisPendentes(iso);
  final decoded = jsonDecode(response.body);
  if (decoded is! List) return [];
  return decoded
      .map((e) =>
          RecebimentoMensalModel.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();
}

Future<void> salvarRecebimentoMensal(RecebimentoMensalModel item) async {
  final id = item.id;
  if (id != null && id.isNotEmpty) {
    await putRecebimentoMensal(id, item.toJsonCadastro());
  } else {
    await postRecebimentoMensal(item.toJsonCadastro());
  }
  await PageDataCache.invalidate(CacheKeys.recebimentosMensais);
  if (item.recebimentoHoje == true) {
    await PageDataCache.invalidate(CacheKeys.receitas);
    await PageDataCache.invalidate(CacheKeys.painel);
    await PageDataCache.invalidate(CacheKeys.contas);
  }
}

Future<void> removerRecebimentoMensal(String id) async {
  await deleteRecebimentoMensal(id);
  await PageDataCache.invalidate(CacheKeys.recebimentosMensais);
}

Future<void> confirmarRecebimentoMensal({
  required String id,
  required String idConta,
  String? dataIso,
}) async {
  await receberRecebimentoMensal(id, idConta: idConta, dataIso: dataIso);
  await PageDataCache.invalidate(CacheKeys.recebimentosMensais);
  await PageDataCache.invalidate(CacheKeys.receitas);
  await PageDataCache.invalidate(CacheKeys.painel);
  await PageDataCache.invalidate(CacheKeys.contas);
}

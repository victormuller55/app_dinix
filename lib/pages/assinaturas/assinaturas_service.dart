import 'dart:convert';

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/cache/paginated_list_cache.dart';
import 'package:app_dinix/models/assinatura_model.dart';
import 'package:app_dinix/models/paginacao_model.dart';
import 'package:app_dinix/services/assinatura_service.dart';

Future<PaginacaoModel<AssinaturaModel>> listarAssinaturas({
  bool forceRefresh = false,
  int pagina = 1,
}) {
  return PaginatedListCache.load(
    key: CacheKeys.assinaturas,
    fromMap: AssinaturaModel.fromMap,
    toMap: (e) => e.toMap(),
    forceRefresh: forceRefresh,
    pagina: pagina,
    fetch: () async {
      final response = await getAssinaturas(numPag: pagina);
      final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      return PaginacaoModel.fromMap(map, AssinaturaModel.fromMap);
    },
  );
}

Future<List<AssinaturaModel>> listarAssinaturasPendentes(DateTime data) async {
  final iso =
      '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  final response = await getAssinaturasPendentes(iso);
  final decoded = jsonDecode(response.body);
  if (decoded is! List) return [];
  return decoded
      .map((e) => AssinaturaModel.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();
}

Future<void> confirmarPagamentoAssinatura({
  required String id,
  required String formaPagamento,
  String? idConta,
  String? idCartaoCredito,
  String? dataIso,
}) async {
  await pagarAssinatura(
    id,
    formaPagamento: formaPagamento,
    idConta: idConta,
    idCartaoCredito: idCartaoCredito,
    dataIso: dataIso,
  );
  await PageDataCache.invalidate(CacheKeys.assinaturas);
  await PageDataCache.invalidatePrefix(CacheKeys.compras);
  await PageDataCache.invalidate(CacheKeys.painel);
  await PageDataCache.invalidate(CacheKeys.contas);
  await PageDataCache.invalidate(CacheKeys.cartoes);
}

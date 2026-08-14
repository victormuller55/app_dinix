import 'dart:convert';

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/cache/paginated_list_cache.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/paginacao_model.dart';
import 'package:app_dinix/services/conta_service.dart';

Future<PaginacaoModel<ContaModel>> listarContas({
  bool forceRefresh = false,
  int pagina = 1,
}) {
  return PaginatedListCache.load(
    key: CacheKeys.contas,
    fromMap: ContaModel.fromMap,
    toMap: (e) => e.toMap(),
    forceRefresh: forceRefresh,
    pagina: pagina,
    fetch: () async {
      final response = await getContas(numPag: pagina);
      final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      return PaginacaoModel.fromMap(map, ContaModel.fromMap);
    },
  );
}

Future<void> excluirConta(String id) async {
  await deleteConta(id);
  await PageDataCache.invalidate(CacheKeys.contas);
}

import 'dart:convert';

import 'package:app_dinix/cache/cache_keys.dart';
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

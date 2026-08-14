import 'dart:convert';

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/paginated_list_cache.dart';
import 'package:app_dinix/models/local_model.dart';
import 'package:app_dinix/models/paginacao_model.dart';
import 'package:app_dinix/services/local_service.dart';

Future<PaginacaoModel<LocalModel>> listarLocais({
  bool forceRefresh = false,
  int pagina = 1,
}) {
  return PaginatedListCache.load(
    key: CacheKeys.locais,
    fromMap: LocalModel.fromMap,
    toMap: (e) => e.toMap(),
    forceRefresh: forceRefresh,
    pagina: pagina,
    fetch: () async {
      final response = await getLocais(numPag: pagina);
      final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      return PaginacaoModel.fromMap(map, LocalModel.fromMap);
    },
  );
}

import 'dart:convert';

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/paginated_list_cache.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/paginacao_model.dart';
import 'package:app_dinix/services/cartao_service.dart';

Future<PaginacaoModel<CartaoCreditoModel>> listarCartoes({
  bool forceRefresh = false,
  int pagina = 1,
}) {
  return PaginatedListCache.load(
    key: CacheKeys.cartoes,
    fromMap: CartaoCreditoModel.fromMap,
    toMap: (e) => e.toMap(),
    forceRefresh: forceRefresh,
    pagina: pagina,
    fetch: () async {
      final response = await getCartoes(numPag: pagina);
      final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      return PaginacaoModel.fromMap(map, CartaoCreditoModel.fromMap);
    },
  );
}

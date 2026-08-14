import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/models/paginacao_model.dart';

/// Leitura/gravação padronizada das listagens paginadas (TTL de 5 min).
class PaginatedListCache {
  PaginatedListCache._();

  static Future<PaginacaoModel<T>?> readPage<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    final cached = await PageDataCache.getJsonMap(key);
    if (cached == null) return null;
    return PaginacaoModel.fromMap(cached, fromMap);
  }

  static Future<void> writePage<T>({
    required String key,
    required PaginacaoModel<T> pagina,
    required Map<String, dynamic> Function(T) toMap,
  }) async {
    await PageDataCache.setJsonMap(key, pagina.toCacheMap(toMap));
  }

  static Future<PaginacaoModel<T>> load<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromMap,
    required Map<String, dynamic> Function(T) toMap,
    required Future<PaginacaoModel<T>> Function() fetch,
    bool forceRefresh = false,
    int pagina = 1,
  }) async {
    if (!forceRefresh && pagina == 1) {
      final cached = await readPage(key: key, fromMap: fromMap);
      if (cached != null) return cached;
    }

    final resultado = await fetch();
    if (pagina == 1) {
      await writePage(key: key, pagina: resultado, toMap: toMap);
    }
    return resultado;
  }
}

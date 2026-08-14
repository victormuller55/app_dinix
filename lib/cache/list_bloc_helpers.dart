import 'package:app_dinix/cache/paginated_list_cache.dart';
import 'package:app_dinix/models/paginacao_model.dart';

/// Helpers compartilhados pelos blocs de listagem com cache de 5 min.
class ListBlocHelpers {
  ListBlocHelpers._();

  static Future<PaginacaoModel<T>?> readCachedPage<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromMap,
    required bool forceRefresh,
  }) {
    if (forceRefresh) return Future.value(null);
    return PaginatedListCache.readPage(key: key, fromMap: fromMap);
  }

  static bool shouldShowFullLoading({
    required bool forceRefresh,
    required bool hasVisibleData,
  }) {
    return !forceRefresh || !hasVisibleData;
  }
}

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/models/local_model.dart';
import 'package:app_dinix/services/local_service.dart';

Future<void> salvarLocal(LocalModel local) async {
  final id = local.id;
  if (id != null && id.isNotEmpty) {
    await putLocal(id, local.toJsonCadastro());
  } else {
    await postLocal(local.toJsonCadastro());
  }
  await PageDataCache.invalidate(CacheKeys.locais);
}

Future<void> removerLocal(String id) async {
  await deleteLocal(id);
  await PageDataCache.invalidate(CacheKeys.locais);
}

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/services/conta_service.dart';

Future<void> salvarConta(ContaModel conta) async {
  final id = conta.id;
  if (id != null && id.isNotEmpty) {
    await putConta(id, conta.toJsonAlterar());
  } else {
    await postConta(conta.toJsonCadastro());
  }
  await PageDataCache.invalidate(CacheKeys.contas);
}

Future<void> removerConta(String id) async {
  await deleteConta(id);
  await PageDataCache.invalidate(CacheKeys.contas);
}

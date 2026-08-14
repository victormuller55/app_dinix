import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/categoria_lookup.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/models/local_model.dart';
import 'package:app_dinix/pages/locais/cadastro_local/cadastro_local_event.dart';
import 'package:app_dinix/services/local_service.dart';

Future<CadastroLocalLookups> carregarLookupsLocal() async {
  final categorias = await listarCategoriasLookup();
  final despesas = categorias.where((c) {
    final tipo = c.tipo;
    return tipo == TipoCategoria.despesa || tipo == TipoCategoria.ambos;
  }).toList();
  return CadastroLocalLookups(
    categorias: despesas.isNotEmpty ? despesas : categorias,
  );
}

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

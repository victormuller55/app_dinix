import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/categoria_lookup.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/receita_model.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_event.dart';
import 'package:app_dinix/services/receita_service.dart';

Future<List<CategoriaModel>> listarOrigensGanho() async {
  final categorias = await listarCategoriasLookup();
  final origens = categorias.where((c) {
    final tipo = c.tipo;
    if (tipo != TipoCategoria.receita && tipo != TipoCategoria.ambos) return false;
    return c.idCategoriaPai != null && c.idCategoriaPai!.isNotEmpty;
  }).toList();

  if (origens.isNotEmpty) return origens;

  return categorias.where((c) {
    final tipo = c.tipo;
    return tipo == TipoCategoria.receita || tipo == TipoCategoria.ambos;
  }).toList();
}

Future<CadastroReceitaLookups> carregarLookupsReceita() async {
  final origens = await listarOrigensGanho();
  final contas = await listarContas(forceRefresh: false);
  return CadastroReceitaLookups(
    origens: origens,
    contas: contas.itens,
  );
}

Future<void> salvarReceita(ReceitaModel receita) async {
  final id = receita.id;
  if (id != null && id.isNotEmpty) {
    await putReceita(id, receita.toJsonCadastro());
  } else {
    await postReceita(receita.toJsonCadastro());
  }
  await PageDataCache.invalidate(CacheKeys.receitas);
  await PageDataCache.invalidate(CacheKeys.contas);
}

Future<void> removerReceita(String id) async {
  await deleteReceita(id);
  await PageDataCache.invalidate(CacheKeys.receitas);
  await PageDataCache.invalidate(CacheKeys.contas);
}

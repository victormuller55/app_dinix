import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/categoria_lookup.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/models/compra_model.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_service.dart';
import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_event.dart';
import 'package:app_dinix/pages/locais/locais_service.dart';
import 'package:app_dinix/services/compra_service.dart';

Future<CadastroCompraLookups> carregarLookupsCompra() async {
  final categorias = await listarCategoriasLookup();
  final contas = await listarContas(forceRefresh: false);
  final cartoes = await listarCartoes(forceRefresh: false);
  final locais = await listarLocais(forceRefresh: false, pagina: 1);
  return CadastroCompraLookups(
    categorias: categorias,
    contas: contas.itens,
    cartoes: cartoes.itens,
    locais: locais.itens,
  );
}

Future<void> salvarCompra(CompraModel compra) async {
  final id = compra.id;
  if (id != null && id.isNotEmpty) {
    await putCompra(id, compra.toJsonAlterar());
  } else {
    await postCompra(compra.toJsonCadastro());
  }
  await PageDataCache.invalidatePrefix(CacheKeys.compras);
}

Future<void> removerCompra(String id) async {
  await deleteCompra(id);
  await PageDataCache.invalidatePrefix(CacheKeys.compras);
}

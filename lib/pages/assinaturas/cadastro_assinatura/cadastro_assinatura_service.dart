import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/categoria_lookup.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/models/assinatura_model.dart';
import 'package:app_dinix/pages/assinaturas/cadastro_assinatura/cadastro_assinatura_event.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_service.dart';
import 'package:app_dinix/services/assinatura_service.dart';

Future<CadastroAssinaturaLookups> carregarLookupsAssinatura() async {
  final categorias = await listarCategoriasLookup();
  final contas = await listarContas(forceRefresh: false);
  final cartoes = await listarCartoes(forceRefresh: false);
  return CadastroAssinaturaLookups(
    categorias: categorias,
    contas: contas.itens,
    cartoes: cartoes.itens,
  );
}

Future<void> salvarAssinatura(AssinaturaModel assinatura) async {
  final id = assinatura.id;
  if (id != null && id.isNotEmpty) {
    await putAssinatura(id, assinatura.toJsonCadastro());
  } else {
    await postAssinatura(assinatura.toJsonCadastro());
  }
  await PageDataCache.invalidate(CacheKeys.assinaturas);
  if (assinatura.pagamentoHoje == true) {
    await PageDataCache.invalidatePrefix(CacheKeys.compras);
    await PageDataCache.invalidate(CacheKeys.painel);
    await PageDataCache.invalidate(CacheKeys.contas);
    await PageDataCache.invalidate(CacheKeys.cartoes);
  }
}

Future<void> removerAssinatura(String id) async {
  await deleteAssinatura(id);
  await PageDataCache.invalidate(CacheKeys.assinaturas);
}

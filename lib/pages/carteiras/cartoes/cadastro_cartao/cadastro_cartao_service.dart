import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/services/cartao_service.dart';

Future<List<ContaModel>> carregarContasCadastroCartao() async {
  final pagina = await listarContas(forceRefresh: true, pagina: 1);
  return pagina.itens;
}

Future<void> salvarCartao(CartaoCreditoModel cartao) async {
  final id = cartao.id;
  if (id != null && id.isNotEmpty) {
    await putCartao(id, cartao.toJsonCadastro());
  } else {
    await postCartao(cartao.toJsonCadastro());
  }
  await PageDataCache.invalidate(CacheKeys.cartoes);
}

Future<void> removerCartao(String id) async {
  await deleteCartao(id);
  await PageDataCache.invalidate(CacheKeys.cartoes);
}

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/services/cartao_service.dart';
import 'dart:convert';

Future<List<ContaModel>> carregarContasCadastroCartao() async {
  final pagina = await listarContas(forceRefresh: true, pagina: 1);
  return pagina.itens;
}

Future<CartaoCreditoModel> salvarCartao(CartaoCreditoModel cartao) async {
  final id = cartao.id;
  final response = (id != null && id.isNotEmpty)
      ? await putCartao(id, cartao.toJsonCadastro())
      : await postCartao(cartao.toJsonCadastro());
  await PageDataCache.invalidate(CacheKeys.cartoes);
  await PageDataCache.invalidate(CacheKeys.painel);
  return CartaoCreditoModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<void> removerCartao(String id) async {
  await deleteCartao(id);
  await PageDataCache.invalidate(CacheKeys.cartoes);
}

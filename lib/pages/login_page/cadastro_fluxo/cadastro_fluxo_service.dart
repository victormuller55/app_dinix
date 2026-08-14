import 'dart:convert';

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/cadastro_fluxo_dados.dart';
import 'package:app_dinix/services/cartao_service.dart';
import 'package:app_dinix/services/conta_service.dart';

Future<void> sincronizarContasECartoesCadastro(CadastroFluxoDados dados) async {
  if (dados.contas.isEmpty) return;

  final idsPorBanco = await _cadastrarContas(dados.contas);

  if (dados.cartoes.isEmpty) return;
  await _cadastrarCartoes(dados.cartoes, idsPorBanco);
}

Future<Map<String, String>> _cadastrarContas(List<ContaFluxoDraft> contas) async {
  final idsPorBanco = <String, String>{};

  for (final draft in contas) {
    final body = ContaModel(
      nomeBanco: draft.banco.nome,
      tipoConta: draft.tipoConta,
      saldoAtual: draft.saldo,
    ).toJsonCadastro();

    final response = await postConta(body);
    final criada = ContaModel.fromMap(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
    final id = criada.id;
    if (id != null && id.isNotEmpty) {
      idsPorBanco[draft.banco.nome] = id;
    }
  }

  await PageDataCache.invalidate(CacheKeys.contas);
  return idsPorBanco;
}

Future<void> _cadastrarCartoes(
  List<CartaoFluxoDraft> cartoes,
  Map<String, String> idsPorBanco,
) async {
  for (final draft in cartoes) {
    final idConta = idsPorBanco[draft.banco.nome];
    if (idConta == null || idConta.isEmpty) continue;

    final cartao = CartaoCreditoModel(
      idConta: idConta,
      nome: draft.nome.trim().isNotEmpty ? draft.nome.trim() : 'Cartão ${draft.banco.nome}',
      banco: draft.banco.nome,
      limite: draft.limite,
      diaFechamento: draft.diaFechamento,
      diaVencimento: draft.diaVencimento,
    );

    await postCartao(cartao.toJsonCadastro());
  }

  await PageDataCache.invalidate(CacheKeys.cartoes);
}

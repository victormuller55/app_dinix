import 'dart:convert';

import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/service/http_helper.dart';
import 'package:app_dinix/models/painel_model.dart';
import 'package:app_dinix/services/painel_service.dart';

Future<PainelResumoModel> carregarPainel({bool forceRefresh = false}) async {
  if (!forceRefresh) {
    final cached = await PageDataCache.getJsonMap(CacheKeys.painel);
    if (cached != null &&
        cached['painel'] != null &&
        cached['saldo_contas'] != null) {
      return PainelResumoModel(
        painel: PainelModel.fromMap(
          Map<String, dynamic>.from(cached['painel'] as Map),
        ),
        saldoContas: (cached['saldo_contas'] as num?)?.toDouble() ?? 0,
        totalInvestimentos:
            (cached['valor_investimentos'] as num?)?.toDouble() ?? 0,
      );
    }
  }

  final response = await getPainel();
  final painel = PainelModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );

  double saldoContas = 0;
  double totalInvestimentos = 0;
  try {
    final patrimonioResponse = await getJson(
      endpoint: AppEndpoints.endpointPatrimonio,
    );
    final patrimonio = Map<String, dynamic>.from(
      jsonDecode(patrimonioResponse.body) as Map,
    );
    saldoContas = parseDecimal(patrimonio['saldo_contas']) ?? 0;
    totalInvestimentos = parseDecimal(patrimonio['valor_investimentos']) ?? 0;
  } catch (_) {
    // Mantém zeros se patrimônio falhar; painel principal ainda carrega.
  }

  await PageDataCache.setJsonMap(CacheKeys.painel, {
    'painel': {
      'mes': painel.mes,
      'ano': painel.ano,
      'receitas': {
        'total': painel.receitas.total,
        'quantidade': painel.receitas.quantidade,
        'total_anterior': painel.receitas.totalAnterior,
        'percentual_variacao': painel.receitas.percentualVariacao,
      },
      'despesas': {
        'total': painel.despesas.total,
        'quantidade': painel.despesas.quantidade,
        'total_anterior': painel.despesas.totalAnterior,
        'percentual_variacao': painel.despesas.percentualVariacao,
      },
      'investimentos': painel.investimentos,
      'disponivel': painel.disponivel,
      'despesas_por_categoria': painel.despesasPorCategoria
          .map((e) => {
                'categoria': e.categoria,
                'valor': e.valor,
                'percentual': e.percentual,
              })
          .toList(),
      'proximos_pagamentos': painel.proximosPagamentos
          .map((e) => {
                'tipo': e.tipo,
                'descricao': e.descricao,
                'valor': e.valor,
                'data_vencimento': e.dataVencimento,
              })
          .toList(),
      'cartoes_credito': painel.cartoes.map((e) => e.toMap()).toList(),
    },
    'saldo_contas': saldoContas,
    'valor_investimentos': totalInvestimentos,
  });

  return PainelResumoModel(
    painel: painel,
    saldoContas: saldoContas,
    totalInvestimentos: totalInvestimentos,
  );
}

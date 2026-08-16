import 'dart:convert';

import 'package:app_dinix/models/assinatura_resumo_model.dart';
import 'package:app_dinix/models/painel_model.dart';
import 'package:app_dinix/models/paginacao_model.dart';
import 'package:app_dinix/models/patrimonio_historico_model.dart';
import 'package:app_dinix/models/patrimonio_model.dart';
import 'package:app_dinix/models/previsao_model.dart';
import 'package:app_dinix/pages/painel/painel_service.dart';
import 'package:app_dinix/services/dashboards_http.dart';

class DashboardsData {
  final PainelModel painel;
  final PatrimonioModel patrimonio;
  final AssinaturaResumoModel assinaturas;
  final PrevisaoModel previsao;
  final List<PatrimonioHistoricoItem> patrimonioHistorico;

  const DashboardsData({
    required this.painel,
    required this.patrimonio,
    required this.assinaturas,
    required this.previsao,
    required this.patrimonioHistorico,
  });
}

Future<DashboardsData> carregarDashboards({bool forceRefresh = false}) async {
  final painelFuture = carregarPainel(forceRefresh: forceRefresh);
  final patrimonioFuture = _carregarPatrimonio();
  final historicoFuture = _carregarPatrimonioHistorico();
  final assinaturasFuture = _carregarAssinaturasResumo();
  final previsaoFuture = _carregarPrevisao();

  final painelResumo = await painelFuture;
  final patrimonio = await patrimonioFuture;
  final historico = await historicoFuture;
  final assinaturas = await assinaturasFuture;
  final previsao = await previsaoFuture;

  final patrimonioFinal = patrimonio ??
      PatrimonioModel(
        saldoContas: painelResumo.saldoContas,
        valorInvestimentos: painelResumo.totalInvestimentos,
        dividas: 0,
        patrimonio:
            painelResumo.saldoContas + painelResumo.totalInvestimentos,
      );

  return DashboardsData(
    painel: painelResumo.painel,
    patrimonio: patrimonioFinal,
    assinaturas: assinaturas,
    previsao: previsao,
    patrimonioHistorico: historico,
  );
}

Future<PatrimonioModel?> _carregarPatrimonio() async {
  try {
    final response = await getPatrimonio();
    return PatrimonioModel.fromMap(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  } catch (_) {
    return null;
  }
}

Future<List<PatrimonioHistoricoItem>> _carregarPatrimonioHistorico() async {
  try {
    final response = await getPatrimonioHistorico(itensPag: 12);
    final page = PaginacaoModel.fromMap(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
      PatrimonioHistoricoItem.fromMap,
    );
    final itens = [...page.itens];
    itens.sort((a, b) {
      final byAno = a.ano.compareTo(b.ano);
      if (byAno != 0) return byAno;
      return a.mes.compareTo(b.mes);
    });
    return itens;
  } catch (_) {
    return const [];
  }
}

Future<AssinaturaResumoModel> _carregarAssinaturasResumo() async {
  try {
    final response = await getAssinaturasResumo();
    return AssinaturaResumoModel.fromMap(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  } catch (_) {
    return AssinaturaResumoModel.empty();
  }
}

Future<PrevisaoModel> _carregarPrevisao() async {
  try {
    final agora = DateTime.now();
    final proximo = DateTime(agora.year, agora.month + 1, 1);
    final response = await getPrevisao(mes: proximo.month, ano: proximo.year);
    return PrevisaoModel.fromMap(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  } catch (_) {
    return PrevisaoModel.empty();
  }
}

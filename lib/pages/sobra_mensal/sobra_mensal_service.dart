import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/models/assinatura_model.dart';
import 'package:app_dinix/models/fatura_cartao_model.dart';
import 'package:app_dinix/models/gasto_mensal_model.dart';
import 'package:app_dinix/models/recebimento_mensal_model.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_service.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_service.dart';
import 'package:app_dinix/pages/gastos_mensais/gastos_mensais_service.dart';
import 'package:app_dinix/pages/recebimentos_mensais/recebimentos_mensais_service.dart';
import 'package:app_dinix/services/fatura_cartao_service.dart';

class MesSobraProjecao {
  final int mes;
  final int ano;
  final double receitas;
  final double gastosMensais;
  final double assinaturas;
  final double faturasCartoes;
  final double totalSaidas;
  final double sobra;

  const MesSobraProjecao({
    required this.mes,
    required this.ano,
    required this.receitas,
    required this.gastosMensais,
    required this.assinaturas,
    required this.faturasCartoes,
    required this.totalSaidas,
    required this.sobra,
  });
}

class SobraMensalResumo {
  final List<MesSobraProjecao> meses;
  final double mediaReceitas;
  final double mediaSaidas;
  final double mediaSobra;

  const SobraMensalResumo({
    required this.meses,
    required this.mediaReceitas,
    required this.mediaSaidas,
    required this.mediaSobra,
  });
}

DateTime? _parseData(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw.length >= 10 ? raw.substring(0, 10) : raw);
}

double _valorMensalEquivalente(double valor, String? recorrencia) {
  switch (recorrencia) {
    case Recorrencia.anual:
      return valor / 12;
    case Recorrencia.semanal:
      return valor * 4;
    default:
      return valor;
  }
}

bool _pagoNoCartao(String? forma) => FormaPagamento.usaCartao(forma);

bool _gastoVigenteNoMes(GastoMensalModel gasto, int mes, int ano) {
  if (gasto.ativo == false) return false;
  if (_pagoNoCartao(gasto.formaPagamento)) return false;

  final inicio = _parseData(gasto.dataInicio);
  final fim = _parseData(gasto.dataFim);
  final dia = (gasto.diaVencimento ?? 1).clamp(1, 28);
  final ocorrencia = DateTime(ano, mes, dia);

  if (inicio != null &&
      ocorrencia.isBefore(DateTime(inicio.year, inicio.month, inicio.day))) {
    return false;
  }
  if (fim != null &&
      ocorrencia.isAfter(DateTime(fim.year, fim.month, fim.day))) {
    return false;
  }

  if (gasto.recorrencia == Recorrencia.anual && inicio != null) {
    return mes == inicio.month;
  }
  return true;
}

bool _assinaturaAtivaNoMes(AssinaturaModel assinatura, int mes, int ano) {
  if ((assinatura.canceladoEm ?? '').isNotEmpty) {
    final cancelado = _parseData(assinatura.canceladoEm);
    if (cancelado != null) {
      final inicioMes = DateTime(ano, mes, 1);
      if (!cancelado.isAfter(inicioMes)) return false;
    }
  }

  final inicio = _parseData(assinatura.dataInicio);
  final dia = (assinatura.diaCobranca ?? 1).clamp(1, 28);
  final ocorrencia = DateTime(ano, mes, dia);
  if (inicio != null &&
      ocorrencia.isBefore(DateTime(inicio.year, inicio.month, inicio.day))) {
    return false;
  }

  if (assinatura.recorrencia == Recorrencia.anual && inicio != null) {
    return mes == inicio.month;
  }
  return true;
}

bool _recebimentoVigenteNoMes(RecebimentoMensalModel item, int mes, int ano) {
  if (item.ativo == false) return false;
  final inicio = _parseData(item.dataInicio);
  final fim = _parseData(item.dataFim);
  final dia = (item.diaRecebimento ?? 1).clamp(1, 28);
  final ocorrencia = DateTime(ano, mes, dia);

  if (inicio != null &&
      ocorrencia.isBefore(DateTime(inicio.year, inicio.month, inicio.day))) {
    return false;
  }
  if (fim != null &&
      ocorrencia.isAfter(DateTime(fim.year, fim.month, fim.day))) {
    return false;
  }
  if (item.recorrencia == Recorrencia.anual && inicio != null) {
    return mes == inicio.month;
  }
  return true;
}

double _valorGastoNoMes(GastoMensalModel gasto, int mes, int ano) {
  if (!_gastoVigenteNoMes(gasto, mes, ano)) return 0;
  final valor = gasto.valor ?? 0;
  if (gasto.recorrencia == Recorrencia.anual) return valor;
  return _valorMensalEquivalente(valor, gasto.recorrencia);
}

double _valorAssinaturaNoMes(AssinaturaModel assinatura, int mes, int ano) {
  if (!_assinaturaAtivaNoMes(assinatura, mes, ano)) return 0;
  final valor = assinatura.valor ?? 0;
  if (assinatura.recorrencia == Recorrencia.anual) return valor;
  return _valorMensalEquivalente(valor, assinatura.recorrencia);
}

double _valorRecebimentoNoMes(RecebimentoMensalModel item, int mes, int ano) {
  if (!_recebimentoVigenteNoMes(item, mes, ano)) return 0;
  final valor = item.valor ?? 0;
  if (item.recorrencia == Recorrencia.anual) return valor;
  return _valorMensalEquivalente(valor, item.recorrencia);
}

double _faturasNoMes(List<FaturaCartaoModel> faturas, int mes, int ano) {
  return faturas
      .where((f) => f.mes == mes && f.ano == ano && !f.isPaga)
      .fold<double>(0, (acc, f) => acc + (f.valor ?? 0));
}

SobraMensalResumo projetarSobraMensal({
  required List<RecebimentoMensalModel> recebimentos,
  required List<GastoMensalModel> gastos,
  required List<AssinaturaModel> assinaturas,
  required List<FaturaCartaoModel> faturas,
  int quantidadeMeses = 6,
  DateTime? aPartirDe,
}) {
  final agora = DateTime.now();
  final base = aPartirDe ?? DateTime(agora.year, agora.month + 1, 1);
  final meses = <MesSobraProjecao>[];

  for (var i = 0; i < quantidadeMeses; i++) {
    final ref = DateTime(base.year, base.month + i, 1);
    final mes = ref.month;
    final ano = ref.year;

    final totalReceitas = recebimentos.fold<double>(
      0,
      (acc, r) => acc + _valorRecebimentoNoMes(r, mes, ano),
    );

    final totalGastos = gastos.fold<double>(
      0,
      (acc, g) => acc + _valorGastoNoMes(g, mes, ano),
    );

    final totalAssinaturas = assinaturas.fold<double>(
      0,
      (acc, a) => acc + _valorAssinaturaNoMes(a, mes, ano),
    );

    final totalFaturas = _faturasNoMes(faturas, mes, ano);
    final saidas = totalGastos + totalAssinaturas + totalFaturas;

    meses.add(
      MesSobraProjecao(
        mes: mes,
        ano: ano,
        receitas: totalReceitas,
        gastosMensais: totalGastos,
        assinaturas: totalAssinaturas,
        faturasCartoes: totalFaturas,
        totalSaidas: saidas,
        sobra: totalReceitas - saidas,
      ),
    );
  }

  final n = meses.isEmpty ? 1 : meses.length;
  final mediaReceitas = meses.fold<double>(0, (a, m) => a + m.receitas) / n;
  final mediaSaidas = meses.fold<double>(0, (a, m) => a + m.totalSaidas) / n;
  final mediaSobra = meses.fold<double>(0, (a, m) => a + m.sobra) / n;

  return SobraMensalResumo(
    meses: meses,
    mediaReceitas: mediaReceitas,
    mediaSaidas: mediaSaidas,
    mediaSobra: mediaSobra,
  );
}

Future<List<FaturaCartaoModel>> _carregarTodasFaturas() async {
  final cartoes = await listarCartoes(forceRefresh: false);
  final todas = <FaturaCartaoModel>[];
  for (final cartao in cartoes.itens) {
    final id = cartao.id;
    if (id == null || id.isEmpty) continue;
    try {
      final faturas = await listarFaturasCartao(id);
      todas.addAll(faturas);
    } catch (_) {
      // Cartão sem faturas ou falha pontual — segue com os demais.
    }
  }
  return todas;
}

Future<SobraMensalResumo> carregarProjecaoSobra({
  bool forceRefresh = false,
  int quantidadeMeses = 6,
}) async {
  final recebimentosFuture =
      listarRecebimentosMensais(forceRefresh: forceRefresh);
  final gastosFuture = listarGastosMensais(forceRefresh: forceRefresh);
  final assinaturasFuture = listarAssinaturas(forceRefresh: forceRefresh);
  final faturasFuture = _carregarTodasFaturas();

  final recebimentos = await recebimentosFuture;
  final gastos = await gastosFuture;
  final assinaturas = await assinaturasFuture;
  final faturas = await faturasFuture;

  return projetarSobraMensal(
    recebimentos: recebimentos.itens,
    gastos: gastos.itens,
    assinaturas: assinaturas.itens,
    faturas: faturas,
    quantidadeMeses: quantidadeMeses,
  );
}

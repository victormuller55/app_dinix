import 'dart:convert';

import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/paginacao_model.dart';
import 'package:app_dinix/models/transacao_model.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_service.dart';
import 'package:app_dinix/services/transacao_service.dart';

enum ExtratoModoFiltro { mes, dia }

class ExtratoFiltro {
  final ExtratoModoFiltro modo;
  final DateTime referencia;
  final bool incluirCredito;

  const ExtratoFiltro({
    required this.modo,
    required this.referencia,
    this.incluirCredito = false,
  });

  factory ExtratoFiltro.mesAtual({bool incluirCredito = false}) {
    final agora = DateTime.now();
    return ExtratoFiltro(
      modo: ExtratoModoFiltro.mes,
      referencia: DateTime(agora.year, agora.month, 1),
      incluirCredito: incluirCredito,
    );
  }

  factory ExtratoFiltro.mes(
    int mes,
    int ano, {
    bool incluirCredito = false,
  }) {
    return ExtratoFiltro(
      modo: ExtratoModoFiltro.mes,
      referencia: DateTime(ano, mes, 1),
      incluirCredito: incluirCredito,
    );
  }

  factory ExtratoFiltro.dia(
    DateTime dia, {
    bool incluirCredito = false,
  }) {
    return ExtratoFiltro(
      modo: ExtratoModoFiltro.dia,
      referencia: DateTime(dia.year, dia.month, dia.day),
      incluirCredito: incluirCredito,
    );
  }

  int get mes => referencia.month;
  int get ano => referencia.year;

  String get dataInicioIso {
    if (modo == ExtratoModoFiltro.dia) {
      return _iso(referencia);
    }
    return _iso(DateTime(ano, mes, 1));
  }

  String get dataFimIso {
    if (modo == ExtratoModoFiltro.dia) {
      return _iso(referencia);
    }
    final ultimo = DateTime(ano, mes + 1, 0);
    return _iso(ultimo);
  }

  bool get eMesAtual {
    if (modo != ExtratoModoFiltro.mes) return false;
    final agora = DateTime.now();
    return mes == agora.month && ano == agora.year;
  }

  ExtratoFiltro copiarCom({
    ExtratoModoFiltro? modo,
    DateTime? referencia,
    bool? incluirCredito,
  }) {
    return ExtratoFiltro(
      modo: modo ?? this.modo,
      referencia: referencia ?? this.referencia,
      incluirCredito: incluirCredito ?? this.incluirCredito,
    );
  }

  ExtratoFiltro avancar() {
    if (modo == ExtratoModoFiltro.dia) {
      return ExtratoFiltro.dia(
        referencia.add(const Duration(days: 1)),
        incluirCredito: incluirCredito,
      );
    }
    return ExtratoFiltro.mes(
      mes == 12 ? 1 : mes + 1,
      mes == 12 ? ano + 1 : ano,
      incluirCredito: incluirCredito,
    );
  }

  ExtratoFiltro voltar() {
    if (modo == ExtratoModoFiltro.dia) {
      return ExtratoFiltro.dia(
        referencia.subtract(const Duration(days: 1)),
        incluirCredito: incluirCredito,
      );
    }
    return ExtratoFiltro.mes(
      mes == 1 ? 12 : mes - 1,
      mes == 1 ? ano - 1 : ano,
      incluirCredito: incluirCredito,
    );
  }

  static String _iso(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}

class ExtratoLookups {
  final Map<String, ContaModel> contasPorId;
  final Map<String, CartaoCreditoModel> cartoesPorId;

  const ExtratoLookups({
    required this.contasPorId,
    required this.cartoesPorId,
  });

  factory ExtratoLookups.empty() => const ExtratoLookups(
        contasPorId: {},
        cartoesPorId: {},
      );
}

Future<ExtratoLookups> carregarLookupsExtrato() async {
  final contasFuture = listarContas();
  final cartoesFuture = listarCartoes();
  final contasPagina = await contasFuture;
  final cartoesPagina = await cartoesFuture;
  return ExtratoLookups(
    contasPorId: {
      for (final c in contasPagina.itens)
        if (c.id != null && c.id!.isNotEmpty) c.id!: c,
    },
    cartoesPorId: {
      for (final c in cartoesPagina.itens)
        if (c.id != null && c.id!.isNotEmpty) c.id!: c,
    },
  );
}

Future<PaginacaoModel<TransacaoModel>> listarExtrato({
  required ExtratoFiltro filtro,
  int pagina = 1,
  int itensPag = 20,
}) async {
  final response = await getTransacoesBusca(
    dataInicio: filtro.dataInicioIso,
    dataFim: filtro.dataFimIso,
    // Sem crédito: só o que mexe no saldo. Com crédito: todos os lançamentos.
    alteraSaldoConta: filtro.incluirCredito ? null : true,
    numPag: pagina,
    itensPag: itensPag,
  );
  final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  return PaginacaoModel.fromMap(map, TransacaoModel.fromMap);
}

String origemTransacao(
  TransacaoModel t,
  ExtratoLookups lookups,
) {
  final idCartao = t.idCartaoCredito;
  if (idCartao != null && idCartao.isNotEmpty) {
    final cartao = lookups.cartoesPorId[idCartao];
    final nome = (cartao?.nome ?? '').trim();
    final banco = (cartao?.banco ?? '').trim();
    if (nome.isNotEmpty && banco.isNotEmpty) return 'Cartão $nome · $banco';
    if (nome.isNotEmpty) return 'Cartão $nome';
    if (banco.isNotEmpty) return 'Cartão $banco';
    return 'Cartão de crédito';
  }

  final idConta = t.idConta;
  if (idConta != null && idConta.isNotEmpty) {
    final conta = lookups.contasPorId[idConta];
    final nome = (conta?.nome ?? '').trim();
    final banco = (conta?.nomeBanco ?? '').trim();
    if (nome.isNotEmpty && banco.isNotEmpty) return 'Conta $nome · $banco';
    if (nome.isNotEmpty) return 'Conta $nome';
    if (banco.isNotEmpty) return 'Conta $banco';
    return 'Conta';
  }

  return '';
}

String dataHoraCobranca(TransacaoModel t) {
  final data = isoParaBr(t.dataTransacao);
  final hora = formataHora(t.criadoEm);
  if (data.isNotEmpty && hora.isNotEmpty) return '$data · $hora';
  if (data.isNotEmpty) return data;
  return hora;
}

import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';

class PeriodoMetricaModel {
  final double total;
  final int quantidade;
  final double totalAnterior;
  final double percentualVariacao;

  PeriodoMetricaModel({
    required this.total,
    required this.quantidade,
    required this.totalAnterior,
    required this.percentualVariacao,
  });

  factory PeriodoMetricaModel.fromMap(Map<String, dynamic>? json) {
    if (json == null) {
      return PeriodoMetricaModel(
        total: 0,
        quantidade: 0,
        totalAnterior: 0,
        percentualVariacao: 0,
      );
    }
    return PeriodoMetricaModel(
      total: parseDecimal(json['total']) ?? 0,
      quantidade: _asInt(json['quantidade']) ?? 0,
      totalAnterior: parseDecimal(json['total_anterior']) ?? 0,
      percentualVariacao: parseDecimal(json['percentual_variacao']) ?? 0,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }
}

class DespesaPorCategoriaModel {
  final String categoria;
  final double valor;
  final double percentual;

  DespesaPorCategoriaModel({
    required this.categoria,
    required this.valor,
    required this.percentual,
  });

  factory DespesaPorCategoriaModel.fromMap(Map<String, dynamic> json) {
    return DespesaPorCategoriaModel(
      categoria: json['categoria']?.toString() ?? '',
      valor: parseDecimal(json['valor']) ?? 0,
      percentual: parseDecimal(json['percentual']) ?? 0,
    );
  }
}

class ProximoPagamentoModel {
  final String tipo;
  final String descricao;
  final double valor;
  final String? dataVencimento;

  ProximoPagamentoModel({
    required this.tipo,
    required this.descricao,
    required this.valor,
    this.dataVencimento,
  });

  factory ProximoPagamentoModel.fromMap(Map<String, dynamic> json) {
    return ProximoPagamentoModel(
      tipo: json['tipo']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      valor: parseDecimal(json['valor']) ?? 0,
      dataVencimento: json['data_vencimento']?.toString(),
    );
  }
}

class PainelModel {
  final int mes;
  final int ano;
  final PeriodoMetricaModel receitas;
  final PeriodoMetricaModel despesas;
  final double investimentos;
  final double disponivel;
  final List<DespesaPorCategoriaModel> despesasPorCategoria;
  final List<ProximoPagamentoModel> proximosPagamentos;
  final List<CartaoCreditoModel> cartoes;

  PainelModel({
    required this.mes,
    required this.ano,
    required this.receitas,
    required this.despesas,
    required this.investimentos,
    required this.disponivel,
    required this.despesasPorCategoria,
    required this.proximosPagamentos,
    required this.cartoes,
  });

  factory PainelModel.fromMap(Map<String, dynamic> json) {
    final categorias = (json['despesas_por_categoria'] as List? ?? [])
        .map((e) => DespesaPorCategoriaModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    final pagamentos = (json['proximos_pagamentos'] as List? ?? [])
        .map((e) => ProximoPagamentoModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    final cartoes = (json['cartoes_credito'] as List? ?? [])
        .map((e) => CartaoCreditoModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return PainelModel(
      mes: _asInt(json['mes']) ?? DateTime.now().month,
      ano: _asInt(json['ano']) ?? DateTime.now().year,
      receitas: PeriodoMetricaModel.fromMap(
        json['receitas'] is Map ? Map<String, dynamic>.from(json['receitas'] as Map) : null,
      ),
      despesas: PeriodoMetricaModel.fromMap(
        json['despesas'] is Map ? Map<String, dynamic>.from(json['despesas'] as Map) : null,
      ),
      investimentos: parseDecimal(json['investimentos']) ?? 0,
      disponivel: parseDecimal(json['disponivel']) ?? 0,
      despesasPorCategoria: categorias,
      proximosPagamentos: pagamentos,
      cartoes: cartoes,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }
}

class PainelResumoModel {
  final PainelModel painel;
  final double saldoContas;

  PainelResumoModel({
    required this.painel,
    required this.saldoContas,
  });
}

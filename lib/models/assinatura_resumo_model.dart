import 'package:app_dinix/function/app_formatters.dart';

class AssinaturaProximoPagamentoModel {
  final String? idAssinatura;
  final String nome;
  final double valor;
  final String? data;

  const AssinaturaProximoPagamentoModel({
    this.idAssinatura,
    required this.nome,
    required this.valor,
    this.data,
  });

  factory AssinaturaProximoPagamentoModel.fromMap(Map<String, dynamic> json) {
    return AssinaturaProximoPagamentoModel(
      idAssinatura: json['id_assinatura']?.toString(),
      nome: json['nome']?.toString() ?? '',
      valor: parseDecimal(json['valor']) ?? 0,
      data: json['data']?.toString(),
    );
  }
}

class AssinaturaResumoModel {
  final double totalMensal;
  final double totalAnual;
  final List<AssinaturaProximoPagamentoModel> proximosPagamentos;

  const AssinaturaResumoModel({
    required this.totalMensal,
    required this.totalAnual,
    required this.proximosPagamentos,
  });

  factory AssinaturaResumoModel.empty() => const AssinaturaResumoModel(
        totalMensal: 0,
        totalAnual: 0,
        proximosPagamentos: [],
      );

  factory AssinaturaResumoModel.fromMap(Map<String, dynamic> json) {
    final proximos = (json['proximos_pagamentos'] as List? ?? [])
        .whereType<Map>()
        .map((e) => AssinaturaProximoPagamentoModel.fromMap(
              Map<String, dynamic>.from(e),
            ))
        .toList();
    return AssinaturaResumoModel(
      totalMensal: parseDecimal(json['total_mensal']) ?? 0,
      totalAnual: parseDecimal(json['total_anual']) ?? 0,
      proximosPagamentos: proximos,
    );
  }
}

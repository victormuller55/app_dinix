import 'package:app_dinix/function/app_formatters.dart';

class PrevisaoModel {
  final int mes;
  final int ano;
  final double receitasPrevistas;
  final double despesasComprometidas;
  final double investimentosPrevistos;
  final double disponivelPrevisto;

  const PrevisaoModel({
    required this.mes,
    required this.ano,
    required this.receitasPrevistas,
    required this.despesasComprometidas,
    required this.investimentosPrevistos,
    required this.disponivelPrevisto,
  });

  factory PrevisaoModel.empty() {
    final agora = DateTime.now();
    final proximo = DateTime(agora.year, agora.month + 1, 1);
    return PrevisaoModel(
      mes: proximo.month,
      ano: proximo.year,
      receitasPrevistas: 0,
      despesasComprometidas: 0,
      investimentosPrevistos: 0,
      disponivelPrevisto: 0,
    );
  }

  factory PrevisaoModel.fromMap(Map<String, dynamic> json) {
    return PrevisaoModel(
      mes: _asInt(json['mes']) ?? DateTime.now().month,
      ano: _asInt(json['ano']) ?? DateTime.now().year,
      receitasPrevistas: parseDecimal(json['receitas_previstas']) ?? 0,
      despesasComprometidas: parseDecimal(json['despesas_comprometidas']) ?? 0,
      investimentosPrevistos: parseDecimal(json['investimentos_previstos']) ?? 0,
      disponivelPrevisto: parseDecimal(json['disponivel_previsto']) ?? 0,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }
}

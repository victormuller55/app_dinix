import 'package:app_dinix/function/app_formatters.dart';

class PatrimonioHistoricoItem {
  final int mes;
  final int ano;
  final double saldoContas;
  final double valorInvestimentos;
  final double dividas;
  final double patrimonio;

  const PatrimonioHistoricoItem({
    required this.mes,
    required this.ano,
    required this.saldoContas,
    required this.valorInvestimentos,
    required this.dividas,
    required this.patrimonio,
  });

  factory PatrimonioHistoricoItem.fromMap(Map<String, dynamic> json) {
    return PatrimonioHistoricoItem(
      mes: _asInt(json['mes']) ?? 1,
      ano: _asInt(json['ano']) ?? DateTime.now().year,
      saldoContas: parseDecimal(json['saldo_contas']) ?? 0,
      valorInvestimentos: parseDecimal(json['valor_investimentos']) ?? 0,
      dividas: parseDecimal(json['dividas']) ?? 0,
      patrimonio: parseDecimal(json['patrimonio']) ?? 0,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }
}

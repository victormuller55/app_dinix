import 'package:app_dinix/function/app_formatters.dart';

class PatrimonioModel {
  final double saldoContas;
  final double valorInvestimentos;
  final double dividas;
  final double patrimonio;

  const PatrimonioModel({
    required this.saldoContas,
    required this.valorInvestimentos,
    required this.dividas,
    required this.patrimonio,
  });

  factory PatrimonioModel.empty() => const PatrimonioModel(
        saldoContas: 0,
        valorInvestimentos: 0,
        dividas: 0,
        patrimonio: 0,
      );

  factory PatrimonioModel.fromMap(Map<String, dynamic> json) {
    return PatrimonioModel(
      saldoContas: parseDecimal(json['saldo_contas']) ?? 0,
      valorInvestimentos: parseDecimal(json['valor_investimentos']) ?? 0,
      dividas: parseDecimal(json['dividas']) ?? 0,
      patrimonio: parseDecimal(json['patrimonio']) ?? 0,
    );
  }
}

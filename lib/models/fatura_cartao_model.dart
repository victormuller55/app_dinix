import 'package:app_dinix/function/app_formatters.dart';

class FaturaCartaoModel {
  String? id;
  String? idCartaoCredito;
  int? ano;
  int? mes;
  double? valor;
  String? status;

  FaturaCartaoModel({
    this.id,
    this.idCartaoCredito,
    this.ano,
    this.mes,
    this.valor,
    this.status,
  });

  factory FaturaCartaoModel.fromMap(Map<String, dynamic> json) {
    return FaturaCartaoModel(
      id: json['id']?.toString(),
      idCartaoCredito: json['id_cartao_credito']?.toString(),
      ano: _asInt(json['ano']),
      mes: _asInt(json['mes']),
      valor: parseDecimal(json['valor']),
      status: json['status']?.toString(),
    );
  }

  bool get isAtual => status == 'atual';
  bool get isProxima => status == 'proxima';
  bool get isFechada => status == 'fechada';
  bool get isPaga => status == 'paga';

  String get rotuloMes {
    const meses = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    final m = mes ?? 0;
    final nome = (m >= 1 && m <= 12) ? meses[m] : 'Mês';
    return '$nome ${ano ?? ''}'.trim();
  }

  String get rotuloStatus {
    return switch (status) {
      'atual' => 'Fatura atual',
      'proxima' => 'Próxima',
      'fechada' => 'Fechada',
      'paga' => 'Paga',
      _ => status ?? '',
    };
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'ano': ano,
      'mes': mes,
      'valor': (valor ?? 0).toStringAsFixed(2),
    };
  }

  Map<String, dynamic> toJsonValor() {
    return {
      'valor': (valor ?? 0).toStringAsFixed(2),
    };
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }
}

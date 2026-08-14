import 'package:app_dinix/function/app_formatters.dart';

class CartaoCreditoModel {
  String? id;
  String? idConta;
  String? nome;
  String? banco;
  double? limite;
  double? limiteUsado;
  double? limiteDisponivel;
  int? diaFechamento;
  int? diaVencimento;

  CartaoCreditoModel({
    this.id,
    this.idConta,
    this.nome,
    this.banco,
    this.limite,
    this.limiteUsado,
    this.limiteDisponivel,
    this.diaFechamento,
    this.diaVencimento,
  });

  factory CartaoCreditoModel.empty() {
    return CartaoCreditoModel(
      nome: '',
      banco: '',
      limite: 0,
      diaFechamento: 10,
      diaVencimento: 17,
    );
  }

  CartaoCreditoModel.fromMap(Map<String, dynamic> json) {
    id = json['id']?.toString();
    idConta = json['id_conta']?.toString();
    nome = json['nome']?.toString();
    banco = json['banco']?.toString();
    limite = parseDecimal(json['limite']);
    limiteUsado = parseDecimal(json['limite_usado']);
    limiteDisponivel = parseDecimal(json['limite_disponivel']);
    diaFechamento = _asInt(json['dia_fechamento']);
    diaVencimento = _asInt(json['dia_vencimento']);
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'id_conta': idConta,
      'nome': nome ?? '',
      'banco': banco ?? '',
      'limite': (limite ?? 0).toStringAsFixed(2),
      'dia_fechamento': diaFechamento ?? 1,
      'dia_vencimento': diaVencimento ?? 1,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_conta': idConta,
      'nome': nome,
      'banco': banco,
      'limite': limite,
      'limite_usado': limiteUsado,
      'limite_disponivel': limiteDisponivel,
      'dia_fechamento': diaFechamento,
      'dia_vencimento': diaVencimento,
    };
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }
}

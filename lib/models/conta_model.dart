import 'package:app_dinix/function/app_formatters.dart';

class ContaModel {
  String? id;
  String? nome;
  String? nomeBanco;
  String? tipoConta;
  double? saldoInicial;
  double? saldoAtual;
  String? cor;
  bool? ativo;
  String? criadoEm;
  String? atualizadoEm;

  ContaModel({
    this.id,
    this.nome,
    this.nomeBanco,
    this.tipoConta,
    this.saldoInicial,
    this.saldoAtual,
    this.cor,
    this.ativo,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory ContaModel.empty() {
    return ContaModel(
      nome: '',
      nomeBanco: '',
      tipoConta: 'conta_corrente',
      saldoInicial: 0,
      cor: '#FF9800',
    );
  }

  ContaModel.fromMap(Map<String, dynamic> json) {
    id = json['id']?.toString();
    nome = json['nome']?.toString();
    nomeBanco = json['nome_banco']?.toString();
    tipoConta = json['tipo_conta']?.toString();
    saldoInicial = parseDecimal(json['saldo_inicial']);
    saldoAtual = parseDecimal(json['saldo_atual']);
    cor = json['cor']?.toString();
    ativo = json['ativo'] is bool ? json['ativo'] as bool : null;
    criadoEm = json['criado_em']?.toString();
    atualizadoEm = json['atualizado_em']?.toString();
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'nome_banco': nomeBanco ?? '',
      'tipo_conta': tipoConta ?? 'conta_corrente',
      'saldo_atual': (saldoAtual ?? saldoInicial ?? 0).toStringAsFixed(2),
    };
  }

  Map<String, dynamic> toJsonAlterar() {
    return {
      'nome_banco': nomeBanco ?? '',
      'tipo_conta': tipoConta ?? 'conta_corrente',
      'saldo_atual': (saldoAtual ?? 0).toStringAsFixed(2),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'nome_banco': nomeBanco,
      'tipo_conta': tipoConta,
      'saldo_inicial': saldoInicial,
      'saldo_atual': saldoAtual,
      'cor': cor,
      'ativo': ativo,
      'criado_em': criadoEm,
      'atualizado_em': atualizadoEm,
    };
  }
}

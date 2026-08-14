import 'package:app_dinix/function/app_formatters.dart';

class AssinaturaModel {
  String? id;
  String? nome;
  String? descricao;
  double? valor;
  String? idCategoria;
  String? formaPagamento;
  String? idConta;
  String? idCartaoCredito;
  int? diaCobranca;
  String? dataInicio;
  String? recorrencia;
  String? dataProximaCobranca;
  String? canceladoEm;
  bool? pagamentoHoje;

  AssinaturaModel({
    this.id,
    this.nome,
    this.descricao,
    this.valor,
    this.idCategoria,
    this.formaPagamento,
    this.idConta,
    this.idCartaoCredito,
    this.diaCobranca,
    this.dataInicio,
    this.recorrencia,
    this.dataProximaCobranca,
    this.canceladoEm,
    this.pagamentoHoje,
  });

  factory AssinaturaModel.empty() {
    return AssinaturaModel(
      nome: '',
      valor: 0,
      formaPagamento: 'cartao_credito',
      diaCobranca: 10,
      recorrencia: 'mensal',
    );
  }

  AssinaturaModel.fromMap(Map<String, dynamic> json) {
    id = json['id']?.toString();
    nome = json['nome']?.toString();
    descricao = json['descricao']?.toString();
    valor = parseDecimal(json['valor']);
    idCategoria = json['id_categoria']?.toString();
    formaPagamento = json['forma_pagamento']?.toString();
    idConta = json['id_conta']?.toString();
    idCartaoCredito = json['id_cartao_credito']?.toString();
    diaCobranca = json['dia_cobranca'] is int
        ? json['dia_cobranca'] as int
        : int.tryParse('${json['dia_cobranca'] ?? ''}');
    dataInicio = json['data_inicio']?.toString();
    recorrencia = json['recorrencia']?.toString();
    dataProximaCobranca = json['data_proxima_cobranca']?.toString();
    canceladoEm = json['cancelado_em']?.toString();
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'nome': nome ?? '',
      'descricao': descricao,
      'valor': (valor ?? 0).toStringAsFixed(2),
      'id_categoria': idCategoria,
      'forma_pagamento': formaPagamento,
      'id_conta': idConta,
      'id_cartao_credito': idCartaoCredito,
      'dia_cobranca': diaCobranca,
      'data_inicio': dataInicio,
      'recorrencia': recorrencia ?? 'mensal',
      if (pagamentoHoje == true) 'pagamento_hoje': true,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      ...toJsonCadastro(),
      'id': id,
      'data_proxima_cobranca': dataProximaCobranca,
      'cancelado_em': canceladoEm,
    };
  }
}

import 'package:app_dinix/function/app_formatters.dart';

class GastoMensalModel {
  String? id;
  String? nome;
  String? descricao;
  double? valor;
  String? idCategoria;
  String? formaPagamento;
  String? idConta;
  String? idCartaoCredito;
  int? diaVencimento;
  String? dataInicio;
  String? dataFim;
  String? recorrencia;
  int? anoUltimoPagamento;
  int? mesUltimoPagamento;
  bool? pagamentoHoje;
  bool? ativo;

  GastoMensalModel({
    this.id,
    this.nome,
    this.descricao,
    this.valor,
    this.idCategoria,
    this.formaPagamento,
    this.idConta,
    this.idCartaoCredito,
    this.diaVencimento,
    this.dataInicio,
    this.dataFim,
    this.recorrencia,
    this.anoUltimoPagamento,
    this.mesUltimoPagamento,
    this.pagamentoHoje,
    this.ativo,
  });

  GastoMensalModel.fromMap(Map<String, dynamic> json) {
    id = json['id']?.toString();
    nome = json['nome']?.toString();
    descricao = json['descricao']?.toString();
    valor = parseDecimal(json['valor']);
    idCategoria = json['id_categoria']?.toString();
    formaPagamento = json['forma_pagamento']?.toString();
    idConta = json['id_conta']?.toString();
    idCartaoCredito = json['id_cartao_credito']?.toString();
    diaVencimento = json['dia_vencimento'] is int
        ? json['dia_vencimento'] as int
        : int.tryParse('${json['dia_vencimento'] ?? ''}');
    dataInicio = json['data_inicio']?.toString();
    dataFim = json['data_fim']?.toString();
    recorrencia = json['recorrencia']?.toString();
    anoUltimoPagamento = json['ano_ultimo_pagamento'] is int
        ? json['ano_ultimo_pagamento'] as int
        : int.tryParse('${json['ano_ultimo_pagamento'] ?? ''}');
    mesUltimoPagamento = json['mes_ultimo_pagamento'] is int
        ? json['mes_ultimo_pagamento'] as int
        : int.tryParse('${json['mes_ultimo_pagamento'] ?? ''}');
    ativo = json['ativo'] as bool?;
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'nome': nome ?? '',
      'descricao': descricao,
      'valor': (valor ?? 0).toStringAsFixed(2),
      if (idCategoria != null && idCategoria!.isNotEmpty)
        'id_categoria': idCategoria,
      'forma_pagamento': formaPagamento,
      'id_conta': idConta,
      'id_cartao_credito': idCartaoCredito,
      'dia_vencimento': diaVencimento,
      'data_inicio': dataInicio,
      'data_fim': dataFim,
      'recorrencia': recorrencia ?? 'mensal',
      if (pagamentoHoje == true) 'pagamento_hoje': true,
    };
  }

  Map<String, dynamic> toMap() => {
        ...toJsonCadastro(),
        'id': id,
        'ano_ultimo_pagamento': anoUltimoPagamento,
        'mes_ultimo_pagamento': mesUltimoPagamento,
        'ativo': ativo,
      };
}

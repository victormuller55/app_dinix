import 'package:app_dinix/function/app_formatters.dart';

class TransacaoModel {
  final String? id;
  final String tipo;
  final double valor;
  final String? dataTransacao;
  final String? descricao;
  final String? idConta;
  final String? idCartaoCredito;
  final String? idCategoria;
  final String? idCompra;
  final String? idParcela;
  final String? idReceita;
  final String? idTransferencia;
  final bool contaNoResultadoMensal;
  final bool alteraSaldoConta;
  final String? criadoEm;

  const TransacaoModel({
    this.id,
    required this.tipo,
    required this.valor,
    this.dataTransacao,
    this.descricao,
    this.idConta,
    this.idCartaoCredito,
    this.idCategoria,
    this.idCompra,
    this.idParcela,
    this.idReceita,
    this.idTransferencia,
    this.contaNoResultadoMensal = true,
    this.alteraSaldoConta = true,
    this.criadoEm,
  });

  factory TransacaoModel.fromMap(Map<String, dynamic> json) {
    return TransacaoModel(
      id: json['id']?.toString(),
      tipo: json['tipo']?.toString() ?? '',
      valor: parseDecimal(json['valor']) ?? 0,
      dataTransacao: json['data_transacao']?.toString(),
      descricao: json['descricao']?.toString(),
      idConta: json['id_conta']?.toString(),
      idCartaoCredito: json['id_cartao_credito']?.toString(),
      idCategoria: json['id_categoria']?.toString(),
      idCompra: json['id_compra']?.toString(),
      idParcela: json['id_parcela']?.toString(),
      idReceita: json['id_receita']?.toString(),
      idTransferencia: json['id_transferencia']?.toString(),
      contaNoResultadoMensal: json['conta_no_resultado_mensal'] == true,
      alteraSaldoConta: json['altera_saldo_conta'] != false,
      criadoEm: json['criado_em']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'valor': valor,
      'data_transacao': dataTransacao,
      'descricao': descricao,
      'id_conta': idConta,
      'id_cartao_credito': idCartaoCredito,
      'id_categoria': idCategoria,
      'id_compra': idCompra,
      'id_parcela': idParcela,
      'id_receita': idReceita,
      'id_transferencia': idTransferencia,
      'conta_no_resultado_mensal': contaNoResultadoMensal,
      'altera_saldo_conta': alteraSaldoConta,
      'criado_em': criadoEm,
    };
  }

  bool get isReceita => tipo == 'receita';
  bool get isDespesa => tipo == 'despesa';
  bool get isInvestimento => tipo == 'investimento';
  bool get isTransferencia => tipo == 'transferencia';
}

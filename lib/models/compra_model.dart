import 'package:app_dinix/function/app_formatters.dart';

class CompraModel {
  String? id;
  String? descricao;
  String? dataCompra;
  String? horaCompra;
  String? criadoEm;
  double? valorTotal;
  String? idCategoria;
  String? idLocal;
  String? formaPagamento;
  String? idConta;
  String? idCartaoCredito;
  String? observacoes;
  int? qtdParcelas;
  double? valorParcela;
  String? dataPrimeiraParcela;
  List<String> idsEtiquetas = const [];

  CompraModel({
    this.id,
    this.descricao,
    this.dataCompra,
    this.horaCompra,
    this.criadoEm,
    this.valorTotal,
    this.idCategoria,
    this.idLocal,
    this.formaPagamento,
    this.idConta,
    this.idCartaoCredito,
    this.observacoes,
    this.qtdParcelas,
    this.valorParcela,
    this.dataPrimeiraParcela,
    this.idsEtiquetas = const [],
  });

  factory CompraModel.empty() {
    return CompraModel(
      descricao: '',
      formaPagamento: 'pix',
      qtdParcelas: 1,
      idsEtiquetas: const [],
    );
  }

  CompraModel.fromMap(Map<String, dynamic> json) {
    id = json['id']?.toString();
    descricao = json['descricao']?.toString();
    dataCompra = json['data_compra']?.toString();
    horaCompra = json['hora_compra']?.toString();
    criadoEm = json['criado_em']?.toString();
    if (horaCompra == null || horaCompra!.isEmpty) {
      horaCompra = formataHora(criadoEm);
    } else {
      horaCompra = formataHora(horaCompra);
    }
    valorTotal = parseDecimal(json['valor_total']);
    idCategoria = json['id_categoria']?.toString();
    idLocal = json['id_local']?.toString();
    formaPagamento = json['forma_pagamento']?.toString();
    idConta = json['id_conta']?.toString();
    idCartaoCredito = json['id_cartao_credito']?.toString();
    observacoes = json['observacoes']?.toString();
    qtdParcelas = json['qtd_parcelas'] is int
        ? json['qtd_parcelas'] as int
        : int.tryParse('${json['qtd_parcelas'] ?? ''}');
    valorParcela = parseDecimal(json['valor_parcela']);
    dataPrimeiraParcela = json['data_primeira_parcela']?.toString();
    final rawTags = json['ids_etiquetas'];
    if (rawTags is List) {
      idsEtiquetas = rawTags.map((e) => e.toString()).toList();
    } else {
      idsEtiquetas = const [];
    }
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'descricao': descricao ?? '',
      'data_compra': dataCompra,
      'hora_compra': horaCompra ?? horaAtual(),
      'valor_total': (valorTotal ?? 0).toStringAsFixed(2),
      'id_categoria': idCategoria,
      'id_local': idLocal,
      'forma_pagamento': formaPagamento,
      'id_conta': idConta,
      'id_cartao_credito': idCartaoCredito,
      'observacoes': observacoes,
      'qtd_parcelas': qtdParcelas ?? 1,
      'data_primeira_parcela': dataPrimeiraParcela,
      'ids_etiquetas': idsEtiquetas,
      'itens': <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> toJsonAlterar() {
    return {
      'descricao': descricao ?? '',
      'data_compra': dataCompra,
      'hora_compra': horaCompra,
      'id_categoria': idCategoria,
      'id_local': idLocal,
      'forma_pagamento': formaPagamento,
      'observacoes': observacoes,
      'ids_etiquetas': idsEtiquetas,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'data_compra': dataCompra,
      'hora_compra': horaCompra,
      'criado_em': criadoEm,
      'valor_total': valorTotal,
      'id_categoria': idCategoria,
      'id_local': idLocal,
      'forma_pagamento': formaPagamento,
      'id_conta': idConta,
      'id_cartao_credito': idCartaoCredito,
      'observacoes': observacoes,
      'qtd_parcelas': qtdParcelas,
      'valor_parcela': valorParcela,
      'data_primeira_parcela': dataPrimeiraParcela,
      'ids_etiquetas': idsEtiquetas,
    };
  }
}

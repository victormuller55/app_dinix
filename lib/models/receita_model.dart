import 'package:app_dinix/function/app_formatters.dart';

class ReceitaModel {
  String? id;
  String? descricao;
  double? valor;
  String? idCategoria;
  String? idConta;
  String? dataRecebimento;
  bool? recorrente;
  String? observacoes;
  String? criadoEm;
  String? atualizadoEm;

  ReceitaModel({
    this.id,
    this.descricao,
    this.valor,
    this.idCategoria,
    this.idConta,
    this.dataRecebimento,
    this.recorrente,
    this.observacoes,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory ReceitaModel.empty() {
    return ReceitaModel(
      descricao: '',
      valor: 0,
      recorrente: false,
    );
  }

  ReceitaModel.fromMap(Map<String, dynamic> json) {
    id = json['id']?.toString();
    descricao = json['descricao']?.toString();
    valor = parseDecimal(json['valor']);
    idCategoria = json['id_categoria']?.toString();
    idConta = json['id_conta']?.toString();
    dataRecebimento = json['data_recebimento']?.toString();
    recorrente = json['recorrente'] is bool ? json['recorrente'] as bool : null;
    observacoes = json['observacoes']?.toString();
    criadoEm = json['criado_em']?.toString();
    atualizadoEm = json['atualizado_em']?.toString();
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'descricao': descricao ?? '',
      'valor': (valor ?? 0).toStringAsFixed(2),
      'id_categoria': idCategoria,
      'id_conta': idConta,
      'data_recebimento': dataRecebimento,
      'recorrente': recorrente ?? false,
      'observacoes': observacoes,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      ...toJsonCadastro(),
      'criado_em': criadoEm,
      'atualizado_em': atualizadoEm,
    };
  }
}

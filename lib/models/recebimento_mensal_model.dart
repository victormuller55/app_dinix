import 'package:app_dinix/function/app_formatters.dart';

class RecebimentoMensalModel {
  String? id;
  String? nome;
  String? descricao;
  double? valor;
  String? idCategoria;
  String? idConta;
  int? diaRecebimento;
  String? dataInicio;
  String? dataFim;
  String? recorrencia;
  int? anoUltimoRecebimento;
  int? mesUltimoRecebimento;
  bool? recebimentoHoje;
  bool? ativo;

  RecebimentoMensalModel({
    this.id,
    this.nome,
    this.descricao,
    this.valor,
    this.idCategoria,
    this.idConta,
    this.diaRecebimento,
    this.dataInicio,
    this.dataFim,
    this.recorrencia,
    this.anoUltimoRecebimento,
    this.mesUltimoRecebimento,
    this.recebimentoHoje,
    this.ativo,
  });

  RecebimentoMensalModel.fromMap(Map<String, dynamic> json) {
    id = json['id']?.toString();
    nome = json['nome']?.toString();
    descricao = json['descricao']?.toString();
    valor = parseDecimal(json['valor']);
    idCategoria = json['id_categoria']?.toString();
    idConta = json['id_conta']?.toString();
    diaRecebimento = json['dia_recebimento'] is int
        ? json['dia_recebimento'] as int
        : int.tryParse('${json['dia_recebimento'] ?? ''}');
    dataInicio = json['data_inicio']?.toString();
    dataFim = json['data_fim']?.toString();
    recorrencia = json['recorrencia']?.toString();
    anoUltimoRecebimento = json['ano_ultimo_recebimento'] is int
        ? json['ano_ultimo_recebimento'] as int
        : int.tryParse('${json['ano_ultimo_recebimento'] ?? ''}');
    mesUltimoRecebimento = json['mes_ultimo_recebimento'] is int
        ? json['mes_ultimo_recebimento'] as int
        : int.tryParse('${json['mes_ultimo_recebimento'] ?? ''}');
    ativo = json['ativo'] as bool?;
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'nome': nome ?? '',
      'descricao': descricao,
      'valor': (valor ?? 0).toStringAsFixed(2),
      if (idCategoria != null && idCategoria!.isNotEmpty)
        'id_categoria': idCategoria,
      'id_conta': idConta,
      'dia_recebimento': diaRecebimento,
      'data_inicio': dataInicio,
      'data_fim': dataFim,
      'recorrencia': recorrencia ?? 'mensal',
      if (recebimentoHoje == true) 'recebimento_hoje': true,
    };
  }

  Map<String, dynamic> toMap() => {
        ...toJsonCadastro(),
        'id': id,
        'ano_ultimo_recebimento': anoUltimoRecebimento,
        'mes_ultimo_recebimento': mesUltimoRecebimento,
        'ativo': ativo,
      };
}

import 'package:muller_package/muller_package.dart';

class ErrorResponseModel {
  DateTime? dataHora;
  int? status;
  String? erro;
  String? mensagem;
  String? caminho;
  Map<String, String>? errosCampos;

  ErrorResponseModel({
    this.dataHora,
    this.status,
    this.erro,
    this.mensagem,
    this.caminho,
    this.errosCampos,
  });

  ErrorResponseModel.fromMap(Map<String, dynamic> json) {
    dataHora = json['data_hora'] != null
        ? DateTime.tryParse(json['data_hora'].toString())
        : (json['timestamp'] != null ? DateTime.tryParse(json['timestamp'].toString()) : null);
    status = json['status'] is int ? json['status'] as int : int.tryParse('${json['status'] ?? ''}');
    erro = (json['erro'] ?? json['error'])?.toString();
    mensagem = (json['mensagem'] ?? json['message'])?.toString();
    caminho = json['caminho']?.toString();

    final rawErrors = json['erros_campos'] ?? json['errors'];
    if (rawErrors is Map) {
      errosCampos = rawErrors.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
  }

  ErrorModel toErrorModel() {
    var texto = mensagem ?? erro ?? 'Erro desconhecido';
    if (errosCampos != null && errosCampos!.isNotEmpty) {
      texto = errosCampos!.values.join('\n');
    }
    return ErrorModel(
      mensagem: texto,
      erro: erro ?? '',
      tipo: status?.toString() ?? '',
    );
  }
}

import 'dart:convert';

import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/models/error_response_model.dart';

ErrorModel errorModelFromException(Object e) {
  if (e is ApiException) {
    final body = e.response.body.toString().trim();
    if (body.isEmpty) {
      return _fallbackError(e.response.statusCode);
    }

    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      if (map.containsKey('mensagem') ||
          map.containsKey('message') ||
          map.containsKey('erro') ||
          map.containsKey('error') ||
          map.containsKey('erros_campos')) {
        final model = ErrorResponseModel.fromMap(map).toErrorModel();
        return _normalizeKnownErrors(e.response.statusCode, model);
      }
      return _normalizeKnownErrors(
        e.response.statusCode,
        ErrorModel.fromMap(map),
      );
    } catch (_) {
      return _fallbackError(e.response.statusCode, body: body);
    }
  }

  return ErrorModel.empty();
}

ErrorModel _normalizeKnownErrors(int statusCode, ErrorModel model) {
  final erro = (model.erro ?? '').toLowerCase();

  if (statusCode == 401 &&
      (erro.contains('nao_autorizado') || erro.contains('não_autorizado') || erro.isEmpty)) {
    return ErrorModel(
      mensagem: 'E-mail ou senha inválidos.',
      erro: model.erro ?? 'nao_autorizado',
      tipo: model.tipo ?? '$statusCode',
    );
  }
  if (statusCode == 409 || erro.contains('conflito')) {
    return ErrorModel(
      mensagem: model.mensagem?.trim().isNotEmpty == true
          ? model.mensagem
          : 'E-mail já cadastrado.',
      erro: model.erro ?? 'conflito',
      tipo: model.tipo ?? '$statusCode',
    );
  }
  if (statusCode == 422 || erro.contains('erro_negocio')) {
    return ErrorModel(
      mensagem: model.mensagem?.trim().isNotEmpty == true
          ? model.mensagem
          : 'Não foi possível concluir a operação.',
      erro: model.erro ?? 'erro_negocio',
      tipo: model.tipo ?? '$statusCode',
    );
  }
  if (statusCode == 403 || erro.contains('proibido')) {
    return ErrorModel(
      mensagem: 'Sem permissão para acessar este recurso.',
      erro: model.erro ?? 'proibido',
      tipo: model.tipo ?? '$statusCode',
    );
  }
  if (statusCode == 404 || erro.contains('nao_encontrado')) {
    return ErrorModel(
      mensagem: model.mensagem?.trim().isNotEmpty == true
          ? model.mensagem
          : 'Registro não encontrado.',
      erro: model.erro ?? 'nao_encontrado',
      tipo: model.tipo ?? '$statusCode',
    );
  }
  if (statusCode == 500 || erro.contains('erro_interno')) {
    return ErrorModel(
      mensagem: 'Tente novamente em instantes.',
      erro: model.erro ?? 'erro_interno',
      tipo: model.tipo ?? '$statusCode',
    );
  }
  return model;
}

ErrorModel _fallbackError(int statusCode, {String? body}) {
  var mensagem = body ?? 'Erro desconhecido';
  if (statusCode == 401) {
    mensagem = 'E-mail ou senha inválidos.';
  } else if (statusCode == 403) {
    mensagem = 'Sem permissão para acessar este recurso.';
  } else if (statusCode == 409) {
    mensagem = 'E-mail já cadastrado.';
  } else if (statusCode == 0) {
    mensagem = 'Sem conexão com o servidor. Verifique a internet.';
  }
  return ErrorModel(mensagem: mensagem, erro: body ?? '', tipo: '$statusCode');
}

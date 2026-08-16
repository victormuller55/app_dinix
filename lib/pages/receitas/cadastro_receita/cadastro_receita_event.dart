import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/receita_model.dart';

abstract class CadastroReceitaEvent {}

class CadastroReceitaLoadEvent extends CadastroReceitaEvent {}

class CadastroReceitaSaveEvent extends CadastroReceitaEvent {
  final ReceitaModel receita;
  /// Se false, grava como recebimento mensal do próximo mês (confirma no dia 1).
  final bool creditarAgora;

  CadastroReceitaSaveEvent({
    required this.receita,
    this.creditarAgora = true,
  });
}

class CadastroReceitaDeleteEvent extends CadastroReceitaEvent {
  final String id;
  CadastroReceitaDeleteEvent({required this.id});
}

class CadastroReceitaLookups {
  final List<CategoriaModel> origens;
  final List<ContaModel> contas;

  CadastroReceitaLookups({
    required this.origens,
    required this.contas,
  });
}

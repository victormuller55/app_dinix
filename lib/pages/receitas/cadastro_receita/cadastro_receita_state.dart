import 'package:muller_package/muller_package.dart';

import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_event.dart';

abstract class CadastroReceitaState {}

class CadastroReceitaInitialState extends CadastroReceitaState {}

class CadastroReceitaLoadingState extends CadastroReceitaState {}

class CadastroReceitaReadyState extends CadastroReceitaState {
  final CadastroReceitaLookups lookups;
  CadastroReceitaReadyState({required this.lookups});
}

class CadastroReceitaSuccessState extends CadastroReceitaState {
  final bool creditarAgora;

  CadastroReceitaSuccessState({this.creditarAgora = true});
}

class CadastroReceitaDeletedState extends CadastroReceitaState {}

class CadastroReceitaErrorState extends CadastroReceitaState {
  final ErrorModel errorModel;
  CadastroReceitaErrorState({required this.errorModel});
}

import 'package:app_dinix/pages/locais/cadastro_local/cadastro_local_event.dart';
import 'package:muller_package/muller_package.dart';

abstract class CadastroLocalState {}

class CadastroLocalInitialState extends CadastroLocalState {}

class CadastroLocalLoadingState extends CadastroLocalState {}

class CadastroLocalReadyState extends CadastroLocalState {
  final CadastroLocalLookups lookups;
  CadastroLocalReadyState({required this.lookups});
}

class CadastroLocalSuccessState extends CadastroLocalState {}

class CadastroLocalDeletedState extends CadastroLocalState {}

class CadastroLocalErrorState extends CadastroLocalState {
  final ErrorModel errorModel;
  CadastroLocalErrorState({required this.errorModel});
}

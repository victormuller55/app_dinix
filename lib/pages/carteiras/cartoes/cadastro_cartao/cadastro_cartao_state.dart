import 'package:app_dinix/models/conta_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class CadastroCartaoState {}

class CadastroCartaoInitialState extends CadastroCartaoState {}

class CadastroCartaoLoadingState extends CadastroCartaoState {}

class CadastroCartaoReadyState extends CadastroCartaoState {
  final List<ContaModel> contas;
  CadastroCartaoReadyState({required this.contas});
}

class CadastroCartaoSuccessState extends CadastroCartaoState {}

class CadastroCartaoDeletedState extends CadastroCartaoState {}

class CadastroCartaoErrorState extends CadastroCartaoState {
  final ErrorModel errorModel;
  CadastroCartaoErrorState({required this.errorModel});
}

import 'package:muller_package/muller_package.dart';

abstract class CadastroContaState {}

class CadastroContaInitialState extends CadastroContaState {}

class CadastroContaLoadingState extends CadastroContaState {}

class CadastroContaSuccessState extends CadastroContaState {}

class CadastroContaDeletedState extends CadastroContaState {}

class CadastroContaErrorState extends CadastroContaState {
  final ErrorModel errorModel;
  CadastroContaErrorState({required this.errorModel});
}

import 'package:muller_package/muller_package.dart';

abstract class CadastroLocalState {}

class CadastroLocalInitialState extends CadastroLocalState {}

class CadastroLocalLoadingState extends CadastroLocalState {}

class CadastroLocalSuccessState extends CadastroLocalState {}

class CadastroLocalDeletedState extends CadastroLocalState {}

class CadastroLocalErrorState extends CadastroLocalState {
  final ErrorModel errorModel;
  CadastroLocalErrorState({required this.errorModel});
}

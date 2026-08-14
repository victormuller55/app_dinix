import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/models/usuario_model.dart';

abstract class CadastroUsuarioState {
  ErrorModel errorModel;
  UsuarioModel usuarioModel;

  CadastroUsuarioState({required this.usuarioModel, required this.errorModel});
}

class CadastroUsuarioInitialState extends CadastroUsuarioState {
  CadastroUsuarioInitialState()
      : super(usuarioModel: UsuarioModel.empty(), errorModel: ErrorModel.empty());
}

class CadastroUsuarioLoadingState extends CadastroUsuarioState {
  CadastroUsuarioLoadingState()
      : super(usuarioModel: UsuarioModel.empty(), errorModel: ErrorModel.empty());
}

class CadastroUsuarioSuccessState extends CadastroUsuarioState {
  CadastroUsuarioSuccessState({required super.usuarioModel})
      : super(errorModel: ErrorModel.empty());
}

class CadastroUsuarioErrorState extends CadastroUsuarioState {
  CadastroUsuarioErrorState({required super.errorModel})
      : super(usuarioModel: UsuarioModel.empty());
}

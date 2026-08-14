import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/models/usuario_model.dart';

abstract class EntrarState {
  ErrorModel errorModel;
  UsuarioModel usuarioModel;

  EntrarState({required this.usuarioModel, required this.errorModel});
}

class EntrarInitialState extends EntrarState {
  EntrarInitialState() : super(usuarioModel: UsuarioModel.empty(), errorModel: ErrorModel.empty());
}

class EntrarLoadingState extends EntrarState {
  EntrarLoadingState() : super(usuarioModel: UsuarioModel.empty(), errorModel: ErrorModel.empty());
}

class EntrarSuccessState extends EntrarState {
  EntrarSuccessState({required super.usuarioModel}) : super(errorModel: ErrorModel.empty());
}

class EntrarErrorState extends EntrarState {
  EntrarErrorState({required super.errorModel}) : super(usuarioModel: UsuarioModel.empty());
}

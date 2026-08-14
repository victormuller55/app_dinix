import 'package:app_dinix/models/usuario_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class PerfilState {}

class PerfilInitialState extends PerfilState {}

class PerfilLoadingState extends PerfilState {}

class PerfilLoadedState extends PerfilState {
  final UsuarioModel usuario;

  PerfilLoadedState({required this.usuario});
}

class PerfilLoggedOutState extends PerfilState {}

class PerfilErrorState extends PerfilState {
  final ErrorModel errorModel;

  PerfilErrorState({required this.errorModel});
}

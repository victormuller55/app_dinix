import 'package:app_dinix/models/usuario_model.dart';

abstract class PerfilEvent {}

class PerfilLoadEvent extends PerfilEvent {
  final bool silencioso;

  PerfilLoadEvent({this.silencioso = false});
}

class PerfilLogoutEvent extends PerfilEvent {}

class PerfilAtualizadoEvent extends PerfilEvent {
  final UsuarioModel usuario;

  PerfilAtualizadoEvent(this.usuario);
}

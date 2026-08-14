import 'package:app_dinix/models/cartao_credito_model.dart';

abstract class CadastroCartaoEvent {}

class CadastroCartaoLoadEvent extends CadastroCartaoEvent {}

class CadastroCartaoSaveEvent extends CadastroCartaoEvent {
  final CartaoCreditoModel cartao;
  CadastroCartaoSaveEvent({required this.cartao});
}

class CadastroCartaoDeleteEvent extends CadastroCartaoEvent {
  final String id;
  CadastroCartaoDeleteEvent({required this.id});
}

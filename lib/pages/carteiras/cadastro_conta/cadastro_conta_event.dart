import 'package:app_dinix/models/conta_model.dart';

abstract class CadastroContaEvent {}

class CadastroContaSaveEvent extends CadastroContaEvent {
  final ContaModel conta;
  CadastroContaSaveEvent({required this.conta});
}

class CadastroContaDeleteEvent extends CadastroContaEvent {
  final String id;
  CadastroContaDeleteEvent({required this.id});
}

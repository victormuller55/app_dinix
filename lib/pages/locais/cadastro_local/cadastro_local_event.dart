import 'package:app_dinix/models/local_model.dart';

abstract class CadastroLocalEvent {}

class CadastroLocalSaveEvent extends CadastroLocalEvent {
  final LocalModel local;
  CadastroLocalSaveEvent({required this.local});
}

class CadastroLocalDeleteEvent extends CadastroLocalEvent {
  final String id;
  CadastroLocalDeleteEvent({required this.id});
}

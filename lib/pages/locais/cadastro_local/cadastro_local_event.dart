import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/local_model.dart';

abstract class CadastroLocalEvent {}

class CadastroLocalLoadEvent extends CadastroLocalEvent {}

class CadastroLocalSaveEvent extends CadastroLocalEvent {
  final LocalModel local;
  CadastroLocalSaveEvent({required this.local});
}

class CadastroLocalDeleteEvent extends CadastroLocalEvent {
  final String id;
  CadastroLocalDeleteEvent({required this.id});
}

class CadastroLocalLookups {
  final List<CategoriaModel> categorias;

  CadastroLocalLookups({required this.categorias});
}

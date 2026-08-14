import 'package:app_dinix/models/assinatura_model.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/conta_model.dart';

abstract class CadastroAssinaturaEvent {}

class CadastroAssinaturaLoadEvent extends CadastroAssinaturaEvent {}

class CadastroAssinaturaSaveEvent extends CadastroAssinaturaEvent {
  final AssinaturaModel assinatura;
  CadastroAssinaturaSaveEvent({required this.assinatura});
}

class CadastroAssinaturaDeleteEvent extends CadastroAssinaturaEvent {
  final String id;
  CadastroAssinaturaDeleteEvent({required this.id});
}

class CadastroAssinaturaLookups {
  final List<CategoriaModel> categorias;
  final List<ContaModel> contas;
  final List<CartaoCreditoModel> cartoes;

  CadastroAssinaturaLookups({
    required this.categorias,
    required this.contas,
    required this.cartoes,
  });
}

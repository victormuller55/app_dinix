import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/compra_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/local_model.dart';

abstract class CadastroCompraEvent {}

class CadastroCompraLoadEvent extends CadastroCompraEvent {}

class CadastroCompraSaveEvent extends CadastroCompraEvent {
  final CompraModel compra;
  CadastroCompraSaveEvent({required this.compra});
}

class CadastroCompraDeleteEvent extends CadastroCompraEvent {
  final String id;
  CadastroCompraDeleteEvent({required this.id});
}

class CadastroCompraLookups {
  final List<CategoriaModel> categorias;
  final List<ContaModel> contas;
  final List<CartaoCreditoModel> cartoes;
  final List<LocalModel> locais;

  CadastroCompraLookups({
    required this.categorias,
    required this.contas,
    required this.cartoes,
    required this.locais,
  });
}

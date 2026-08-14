import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_event.dart';
import 'package:muller_package/muller_package.dart';

abstract class CadastroCompraState {}

class CadastroCompraInitialState extends CadastroCompraState {}

class CadastroCompraLoadingState extends CadastroCompraState {}

class CadastroCompraReadyState extends CadastroCompraState {
  final CadastroCompraLookups lookups;
  CadastroCompraReadyState({required this.lookups});
}

class CadastroCompraSuccessState extends CadastroCompraState {}

class CadastroCompraDeletedState extends CadastroCompraState {}

class CadastroCompraErrorState extends CadastroCompraState {
  final ErrorModel errorModel;
  CadastroCompraErrorState({required this.errorModel});
}

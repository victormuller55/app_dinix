import 'package:app_dinix/pages/compras/compras_state.dart';

abstract class ComprasEvent {}

class ComprasLoadEvent extends ComprasEvent {
  final bool forceRefresh;
  ComprasLoadEvent({this.forceRefresh = false});
}

class ComprasLoadMoreEvent extends ComprasEvent {}

class ComprasAlterarFiltroEvent extends ComprasEvent {
  final FiltroCompras filtro;
  ComprasAlterarFiltroEvent(this.filtro);
}

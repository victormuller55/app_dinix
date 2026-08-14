import 'package:bloc/bloc.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_event.dart';
import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_service.dart';
import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_state.dart';

class CadastroCompraBloc extends Bloc<CadastroCompraEvent, CadastroCompraState> {
  CadastroCompraBloc() : super(CadastroCompraInitialState()) {
    on<CadastroCompraLoadEvent>(_carregar);
    on<CadastroCompraSaveEvent>(_salvar);
    on<CadastroCompraDeleteEvent>(_excluir);
  }

  Future<void> _carregar(
    CadastroCompraLoadEvent event,
    Emitter<CadastroCompraState> emit,
  ) async {
    emit(CadastroCompraLoadingState());
    try {
      emit(CadastroCompraReadyState(lookups: await carregarLookupsCompra()));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroCompraErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _salvar(
    CadastroCompraSaveEvent event,
    Emitter<CadastroCompraState> emit,
  ) async {
    emit(CadastroCompraLoadingState());
    try {
      await salvarCompra(event.compra);
      emit(CadastroCompraSuccessState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroCompraErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _excluir(
    CadastroCompraDeleteEvent event,
    Emitter<CadastroCompraState> emit,
  ) async {
    emit(CadastroCompraLoadingState());
    try {
      await removerCompra(event.id);
      emit(CadastroCompraDeletedState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroCompraErrorState(errorModel: errorModelFromException(e)));
    }
  }
}

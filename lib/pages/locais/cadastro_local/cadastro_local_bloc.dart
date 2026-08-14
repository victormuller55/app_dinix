import 'package:bloc/bloc.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/pages/locais/cadastro_local/cadastro_local_event.dart';
import 'package:app_dinix/pages/locais/cadastro_local/cadastro_local_service.dart';
import 'package:app_dinix/pages/locais/cadastro_local/cadastro_local_state.dart';

class CadastroLocalBloc extends Bloc<CadastroLocalEvent, CadastroLocalState> {
  CadastroLocalBloc() : super(CadastroLocalInitialState()) {
    on<CadastroLocalLoadEvent>(_carregar);
    on<CadastroLocalSaveEvent>(_salvar);
    on<CadastroLocalDeleteEvent>(_excluir);
  }

  Future<void> _carregar(
    CadastroLocalLoadEvent event,
    Emitter<CadastroLocalState> emit,
  ) async {
    emit(CadastroLocalLoadingState());
    try {
      emit(CadastroLocalReadyState(lookups: await carregarLookupsLocal()));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroLocalErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _salvar(CadastroLocalSaveEvent event, Emitter<CadastroLocalState> emit) async {
    emit(CadastroLocalLoadingState());
    try {
      await salvarLocal(event.local);
      emit(CadastroLocalSuccessState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroLocalErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _excluir(CadastroLocalDeleteEvent event, Emitter<CadastroLocalState> emit) async {
    emit(CadastroLocalLoadingState());
    try {
      await removerLocal(event.id);
      emit(CadastroLocalDeletedState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroLocalErrorState(errorModel: errorModelFromException(e)));
    }
  }
}

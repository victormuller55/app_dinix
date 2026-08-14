import 'package:bloc/bloc.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/pages/assinaturas/cadastro_assinatura/cadastro_assinatura_event.dart';
import 'package:app_dinix/pages/assinaturas/cadastro_assinatura/cadastro_assinatura_service.dart';
import 'package:app_dinix/pages/assinaturas/cadastro_assinatura/cadastro_assinatura_state.dart';

class CadastroAssinaturaBloc extends Bloc<CadastroAssinaturaEvent, CadastroAssinaturaState> {
  CadastroAssinaturaBloc() : super(CadastroAssinaturaInitialState()) {
    on<CadastroAssinaturaLoadEvent>(_carregar);
    on<CadastroAssinaturaSaveEvent>(_salvar);
    on<CadastroAssinaturaDeleteEvent>(_excluir);
  }

  Future<void> _carregar(
    CadastroAssinaturaLoadEvent event,
    Emitter<CadastroAssinaturaState> emit,
  ) async {
    emit(CadastroAssinaturaLoadingState());
    try {
      emit(CadastroAssinaturaReadyState(lookups: await carregarLookupsAssinatura()));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroAssinaturaErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _salvar(
    CadastroAssinaturaSaveEvent event,
    Emitter<CadastroAssinaturaState> emit,
  ) async {
    emit(CadastroAssinaturaLoadingState());
    try {
      await salvarAssinatura(event.assinatura);
      emit(CadastroAssinaturaSuccessState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroAssinaturaErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _excluir(
    CadastroAssinaturaDeleteEvent event,
    Emitter<CadastroAssinaturaState> emit,
  ) async {
    emit(CadastroAssinaturaLoadingState());
    try {
      await removerAssinatura(event.id);
      emit(CadastroAssinaturaDeletedState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroAssinaturaErrorState(errorModel: errorModelFromException(e)));
    }
  }
}

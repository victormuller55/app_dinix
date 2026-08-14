import 'package:bloc/bloc.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/pages/carteiras/cadastro_conta/cadastro_conta_event.dart';
import 'package:app_dinix/pages/carteiras/cadastro_conta/cadastro_conta_service.dart';
import 'package:app_dinix/pages/carteiras/cadastro_conta/cadastro_conta_state.dart';

class CadastroContaBloc extends Bloc<CadastroContaEvent, CadastroContaState> {
  CadastroContaBloc() : super(CadastroContaInitialState()) {
    on<CadastroContaSaveEvent>(_salvar);
    on<CadastroContaDeleteEvent>(_excluir);
  }

  Future<void> _salvar(
    CadastroContaSaveEvent event,
    Emitter<CadastroContaState> emit,
  ) async {
    emit(CadastroContaLoadingState());
    try {
      await salvarConta(event.conta);
      emit(CadastroContaSuccessState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroContaErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _excluir(
    CadastroContaDeleteEvent event,
    Emitter<CadastroContaState> emit,
  ) async {
    emit(CadastroContaLoadingState());
    try {
      await removerConta(event.id);
      emit(CadastroContaDeletedState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroContaErrorState(errorModel: errorModelFromException(e)));
    }
  }
}

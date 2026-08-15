import 'package:bloc/bloc.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cadastro_cartao/cadastro_cartao_event.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cadastro_cartao/cadastro_cartao_service.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cadastro_cartao/cadastro_cartao_state.dart';

class CadastroCartaoBloc extends Bloc<CadastroCartaoEvent, CadastroCartaoState> {
  CadastroCartaoBloc() : super(CadastroCartaoInitialState()) {
    on<CadastroCartaoLoadEvent>(_carregar);
    on<CadastroCartaoSaveEvent>(_salvar);
    on<CadastroCartaoDeleteEvent>(_excluir);
  }

  Future<void> _carregar(
    CadastroCartaoLoadEvent event,
    Emitter<CadastroCartaoState> emit,
  ) async {
    emit(CadastroCartaoLoadingState());
    try {
      final contas = await carregarContasCadastroCartao();
      emit(CadastroCartaoReadyState(contas: contas));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroCartaoErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _salvar(
    CadastroCartaoSaveEvent event,
    Emitter<CadastroCartaoState> emit,
  ) async {
    emit(CadastroCartaoLoadingState());
    try {
      final salvo = await salvarCartao(event.cartao);
      emit(CadastroCartaoSuccessState(cartao: salvo));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroCartaoErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _excluir(
    CadastroCartaoDeleteEvent event,
    Emitter<CadastroCartaoState> emit,
  ) async {
    emit(CadastroCartaoLoadingState());
    try {
      await removerCartao(event.id);
      emit(CadastroCartaoDeletedState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroCartaoErrorState(errorModel: errorModelFromException(e)));
    }
  }
}

import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_event.dart';
import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_service.dart';
import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_state.dart';
import 'package:bloc/bloc.dart';

class CadastroReceitaBloc extends Bloc<CadastroReceitaEvent, CadastroReceitaState> {
  CadastroReceitaBloc() : super(CadastroReceitaInitialState()) {
    on<CadastroReceitaLoadEvent>(_carregar);
    on<CadastroReceitaSaveEvent>(_salvar);
    on<CadastroReceitaDeleteEvent>(_excluir);
  }

  Future<void> _carregar(
    CadastroReceitaLoadEvent event,
    Emitter<CadastroReceitaState> emit,
  ) async {
    emit(CadastroReceitaLoadingState());
    try {
      emit(CadastroReceitaReadyState(lookups: await carregarLookupsReceita()));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroReceitaErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _salvar(
    CadastroReceitaSaveEvent event,
    Emitter<CadastroReceitaState> emit,
  ) async {
    emit(CadastroReceitaLoadingState());
    try {
      if (event.creditarAgora) {
        await salvarReceita(event.receita);
      } else {
        await salvarGanhoParaProximoMes(event.receita);
      }
      emit(CadastroReceitaSuccessState(creditarAgora: event.creditarAgora));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroReceitaErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _excluir(
    CadastroReceitaDeleteEvent event,
    Emitter<CadastroReceitaState> emit,
  ) async {
    emit(CadastroReceitaLoadingState());
    try {
      await removerReceita(event.id);
      emit(CadastroReceitaDeletedState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroReceitaErrorState(errorModel: errorModelFromException(e)));
    }
  }
}

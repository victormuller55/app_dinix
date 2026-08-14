import 'package:app_dinix/cache/list_bloc_helpers.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/pages/painel/painel_event.dart';
import 'package:app_dinix/pages/painel/painel_service.dart';
import 'package:app_dinix/pages/painel/painel_state.dart';
import 'package:bloc/bloc.dart';

class PainelBloc extends Bloc<PainelEvent, PainelState> {
  PainelBloc() : super(PainelInitialState()) {
    on<PainelLoadEvent>(_carregar);
  }

  Future<void> _carregar(PainelLoadEvent event, Emitter<PainelState> emit) async {
    final temDados = state is PainelSuccessState;

    if (ListBlocHelpers.shouldShowFullLoading(
      forceRefresh: event.forceRefresh,
      hasVisibleData: temDados,
    )) {
      emit(PainelLoadingState());
    }

    try {
      final resumo = await carregarPainel(forceRefresh: event.forceRefresh);
      emit(PainelSuccessState(resumo: resumo));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(PainelErrorState(errorModel: errorModelFromException(e)));
    }
  }
}

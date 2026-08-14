import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/list_bloc_helpers.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/models/receita_model.dart';
import 'package:app_dinix/pages/receitas/receitas_event.dart';
import 'package:app_dinix/pages/receitas/receitas_service.dart';
import 'package:app_dinix/pages/receitas/receitas_state.dart';
import 'package:bloc/bloc.dart';

class ReceitasBloc extends Bloc<ReceitasEvent, ReceitasState> {
  ReceitasBloc() : super(ReceitasInitialState()) {
    on<ReceitasLoadEvent>(_carregar);
    on<ReceitasLoadMoreEvent>(_carregarMais);
  }

  Future<void> _carregar(ReceitasLoadEvent event, Emitter<ReceitasState> emit) async {
    final temLista = state is ReceitasSuccessState;

    final cached = await ListBlocHelpers.readCachedPage(
      key: CacheKeys.receitas,
      fromMap: ReceitaModel.fromMap,
      forceRefresh: event.forceRefresh,
    );
    if (cached != null) {
      final contasPorId = await mapearContasReceitas();
      final categoriasPorId = await mapearCategoriasReceitas();
      emit(
        ReceitasSuccessState(
          receitas: cached.itens,
          numPag: cached.numPag,
          maxPag: cached.maxPag,
          contasPorId: contasPorId,
          categoriasPorId: categoriasPorId,
          resumoDia: montarResumoDiaReceitas(receitas: cached.itens),
        ),
      );
      return;
    }

    if (ListBlocHelpers.shouldShowFullLoading(
      forceRefresh: event.forceRefresh,
      hasVisibleData: temLista,
    )) {
      emit(ReceitasLoadingState());
    }

    try {
      final pagina = await listarReceitas(forceRefresh: event.forceRefresh);
      final contasPorId = await mapearContasReceitas();
      final categoriasPorId = await mapearCategoriasReceitas();
      emit(
        ReceitasSuccessState(
          receitas: pagina.itens,
          numPag: pagina.numPag,
          maxPag: pagina.maxPag,
          contasPorId: contasPorId,
          categoriasPorId: categoriasPorId,
          resumoDia: montarResumoDiaReceitas(receitas: pagina.itens),
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(ReceitasErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _carregarMais(ReceitasLoadMoreEvent event, Emitter<ReceitasState> emit) async {
    final atual = state;
    if (atual is! ReceitasSuccessState || atual.loadingMore || !atual.temProximaPagina) return;
    emit(atual.copyWith(loadingMore: true));
    try {
      final pagina = await listarReceitas(forceRefresh: true, pagina: atual.numPag + 1);
      final receitas = [...atual.receitas, ...pagina.itens];
      emit(
        atual.copyWith(
          receitas: receitas,
          numPag: pagina.numPag,
          maxPag: pagina.maxPag,
          loadingMore: false,
          resumoDia: montarResumoDiaReceitas(receitas: receitas),
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(atual.copyWith(loadingMore: false));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/list_bloc_helpers.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/models/local_model.dart';
import 'package:app_dinix/pages/locais/locais_event.dart';
import 'package:app_dinix/pages/locais/locais_service.dart';
import 'package:app_dinix/pages/locais/locais_state.dart';

class LocaisBloc extends Bloc<LocaisEvent, LocaisState> {
  LocaisBloc() : super(LocaisInitialState()) {
    on<LocaisLoadEvent>(_carregar);
    on<LocaisLoadMoreEvent>(_carregarMais);
  }

  Future<void> _carregar(LocaisLoadEvent event, Emitter<LocaisState> emit) async {
    final temLista = state is LocaisSuccessState;

    final cached = await ListBlocHelpers.readCachedPage(
      key: CacheKeys.locais,
      fromMap: LocalModel.fromMap,
      forceRefresh: event.forceRefresh,
    );
    if (cached != null) {
      emit(LocaisSuccessState(
        locais: cached.itens,
        numPag: cached.numPag,
        maxPag: cached.maxPag,
      ));
      return;
    }

    if (ListBlocHelpers.shouldShowFullLoading(
      forceRefresh: event.forceRefresh,
      hasVisibleData: temLista,
    )) {
      emit(LocaisLoadingState());
    }

    try {
      final pagina = await listarLocais(forceRefresh: event.forceRefresh);
      emit(LocaisSuccessState(
        locais: pagina.itens,
        numPag: pagina.numPag,
        maxPag: pagina.maxPag,
      ));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(LocaisErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _carregarMais(LocaisLoadMoreEvent event, Emitter<LocaisState> emit) async {
    final atual = state;
    if (atual is! LocaisSuccessState || atual.loadingMore || !atual.temProximaPagina) return;
    emit(atual.copyWith(loadingMore: true));
    try {
      final pagina = await listarLocais(forceRefresh: true, pagina: atual.numPag + 1);
      emit(atual.copyWith(
        locais: [...atual.locais, ...pagina.itens],
        numPag: pagina.numPag,
        maxPag: pagina.maxPag,
        loadingMore: false,
      ));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(atual.copyWith(loadingMore: false));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/list_bloc_helpers.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/models/assinatura_model.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_event.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_service.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_state.dart';

class AssinaturasBloc extends Bloc<AssinaturasEvent, AssinaturasState> {
  AssinaturasBloc() : super(AssinaturasInitialState()) {
    on<AssinaturasLoadEvent>(_carregar);
    on<AssinaturasLoadMoreEvent>(_carregarMais);
  }

  Future<void> _carregar(AssinaturasLoadEvent event, Emitter<AssinaturasState> emit) async {
    final temLista = state is AssinaturasSuccessState;

    final cached = await ListBlocHelpers.readCachedPage(
      key: CacheKeys.assinaturas,
      fromMap: AssinaturaModel.fromMap,
      forceRefresh: event.forceRefresh,
    );
    if (cached != null) {
      emit(AssinaturasSuccessState(
        assinaturas: cached.itens,
        numPag: cached.numPag,
        maxPag: cached.maxPag,
      ));
      return;
    }

    if (ListBlocHelpers.shouldShowFullLoading(
      forceRefresh: event.forceRefresh,
      hasVisibleData: temLista,
    )) {
      emit(AssinaturasLoadingState());
    }

    try {
      final pagina = await listarAssinaturas(forceRefresh: event.forceRefresh);
      emit(AssinaturasSuccessState(
        assinaturas: pagina.itens,
        numPag: pagina.numPag,
        maxPag: pagina.maxPag,
      ));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(AssinaturasErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _carregarMais(AssinaturasLoadMoreEvent event, Emitter<AssinaturasState> emit) async {
    final atual = state;
    if (atual is! AssinaturasSuccessState || atual.loadingMore || !atual.temProximaPagina) return;
    emit(atual.copyWith(loadingMore: true));
    try {
      final pagina = await listarAssinaturas(forceRefresh: true, pagina: atual.numPag + 1);
      emit(atual.copyWith(
        assinaturas: [...atual.assinaturas, ...pagina.itens],
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

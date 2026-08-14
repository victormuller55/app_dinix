import 'package:bloc/bloc.dart';
import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/list_bloc_helpers.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_event.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_service.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_state.dart';

class CartoesBloc extends Bloc<CartoesEvent, CartoesState> {
  CartoesBloc() : super(CartoesInitialState()) {
    on<CartoesLoadEvent>(_carregar);
    on<CartoesLoadMoreEvent>(_carregarMais);
  }

  Future<void> _carregar(
    CartoesLoadEvent event,
    Emitter<CartoesState> emit,
  ) async {
    final temLista = state is CartoesSuccessState;

    final cached = await ListBlocHelpers.readCachedPage(
      key: CacheKeys.cartoes,
      fromMap: CartaoCreditoModel.fromMap,
      forceRefresh: event.forceRefresh,
    );
    if (cached != null) {
      emit(
        CartoesSuccessState(
          cartoes: cached.itens,
          numPag: cached.numPag,
          maxPag: cached.maxPag,
        ),
      );
      return;
    }

    if (ListBlocHelpers.shouldShowFullLoading(
      forceRefresh: event.forceRefresh,
      hasVisibleData: temLista,
    )) {
      emit(CartoesLoadingState());
    }

    try {
      final pagina = await listarCartoes(forceRefresh: event.forceRefresh);
      emit(
        CartoesSuccessState(
          cartoes: pagina.itens,
          numPag: pagina.numPag,
          maxPag: pagina.maxPag,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CartoesErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _carregarMais(
    CartoesLoadMoreEvent event,
    Emitter<CartoesState> emit,
  ) async {
    final atual = state;
    if (atual is! CartoesSuccessState) return;
    if (atual.loadingMore || !atual.temProximaPagina) return;
    emit(atual.copyWith(loadingMore: true));
    try {
      final pagina = await listarCartoes(
        forceRefresh: true,
        pagina: atual.numPag + 1,
      );
      emit(
        atual.copyWith(
          cartoes: [...atual.cartoes, ...pagina.itens],
          numPag: pagina.numPag,
          maxPag: pagina.maxPag,
          loadingMore: false,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(atual.copyWith(loadingMore: false));
    }
  }
}

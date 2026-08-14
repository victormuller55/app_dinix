import 'package:bloc/bloc.dart';
import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/list_bloc_helpers.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/pages/carteiras/carteiras_event.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/pages/carteiras/carteiras_state.dart';

class CarteirasBloc extends Bloc<CarteirasEvent, CarteirasState> {
  CarteirasBloc() : super(CarteirasInitialState()) {
    on<CarteirasLoadEvent>(_carregar);
    on<CarteirasLoadMoreEvent>(_carregarMais);
    on<CarteirasDeleteEvent>(_excluir);
  }

  Future<void> _carregar(
    CarteirasLoadEvent event,
    Emitter<CarteirasState> emit,
  ) async {
    final temLista = state is CarteirasSuccessState;

    final cached = await ListBlocHelpers.readCachedPage(
      key: CacheKeys.contas,
      fromMap: ContaModel.fromMap,
      forceRefresh: event.forceRefresh,
    );
    if (cached != null) {
      emit(
        CarteirasSuccessState(
          contas: cached.itens,
          numPag: cached.numPag,
          maxPag: cached.maxPag,
          maxItens: cached.maxItens,
        ),
      );
      return;
    }

    if (ListBlocHelpers.shouldShowFullLoading(
      forceRefresh: event.forceRefresh,
      hasVisibleData: temLista,
    )) {
      emit(CarteirasLoadingState());
    }

    try {
      final pagina = await listarContas(forceRefresh: event.forceRefresh);
      emit(
        CarteirasSuccessState(
          contas: pagina.itens,
          numPag: pagina.numPag,
          maxPag: pagina.maxPag,
          maxItens: pagina.maxItens,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CarteirasErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _carregarMais(
    CarteirasLoadMoreEvent event,
    Emitter<CarteirasState> emit,
  ) async {
    final atual = state;
    if (atual is! CarteirasSuccessState) return;
    if (atual.loadingMore || !atual.temProximaPagina) return;

    emit(atual.copyWith(loadingMore: true));
    try {
      final pagina = await listarContas(
        forceRefresh: true,
        pagina: atual.numPag + 1,
      );
      emit(
        atual.copyWith(
          contas: [...atual.contas, ...pagina.itens],
          numPag: pagina.numPag,
          maxPag: pagina.maxPag,
          maxItens: pagina.maxItens,
          loadingMore: false,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(atual.copyWith(loadingMore: false));
    }
  }

  Future<void> _excluir(
    CarteirasDeleteEvent event,
    Emitter<CarteirasState> emit,
  ) async {
    emit(CarteirasLoadingState());
    try {
      await excluirConta(event.id);
      final pagina = await listarContas(forceRefresh: true);
      emit(
        CarteirasSuccessState(
          contas: pagina.itens,
          numPag: pagina.numPag,
          maxPag: pagina.maxPag,
          maxItens: pagina.maxItens,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CarteirasErrorState(errorModel: errorModelFromException(e)));
    }
  }
}

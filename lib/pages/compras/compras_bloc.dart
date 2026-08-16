import 'package:bloc/bloc.dart';
import 'package:app_dinix/cache/list_bloc_helpers.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/models/assinatura_model.dart';
import 'package:app_dinix/models/compra_model.dart';
import 'package:app_dinix/models/gasto_mensal_model.dart';
import 'package:app_dinix/models/recebimento_mensal_model.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_service.dart';
import 'package:app_dinix/pages/compras/compras_event.dart';
import 'package:app_dinix/pages/compras/compras_service.dart';
import 'package:app_dinix/pages/compras/compras_state.dart';
import 'package:app_dinix/pages/gastos_mensais/gastos_mensais_service.dart';
import 'package:app_dinix/pages/recebimentos_mensais/recebimentos_mensais_service.dart';

class ComprasBloc extends Bloc<ComprasEvent, ComprasState> {
  FiltroCompras _filtro = FiltroCompras.hoje();

  ComprasBloc() : super(ComprasInitialState()) {
    on<ComprasLoadEvent>(_carregar);
    on<ComprasLoadMoreEvent>(_carregarMais);
    on<ComprasAlterarFiltroEvent>(_alterarFiltro);
  }

  Future<void> _alterarFiltro(
    ComprasAlterarFiltroEvent event,
    Emitter<ComprasState> emit,
  ) async {
    _filtro = event.filtro;
    emit(ComprasLoadingState(filtro: _filtro));
    await _carregar(ComprasLoadEvent(forceRefresh: true), emit);
  }

  Future<List<GastoMensalModel>> _gastosPendentesDoDia() async {
    try {
      return await listarGastosMensaisPendentes(_filtro.dataSelecionada);
    } catch (_) {
      return [];
    }
  }

  Future<List<AssinaturaModel>> _assinaturasPendentesDoDia() async {
    try {
      return await listarAssinaturasPendentes(_filtro.dataSelecionada);
    } catch (_) {
      return [];
    }
  }

  Future<List<RecebimentoMensalModel>> _recebimentosPendentesDoDia() async {
    try {
      return await listarRecebimentosMensaisPendentes(_filtro.dataSelecionada);
    } catch (_) {
      return [];
    }
  }

  Future<void> _carregar(
    ComprasLoadEvent event,
    Emitter<ComprasState> emit,
  ) async {
    final temLista = state is ComprasSuccessState;

    final cached = await ListBlocHelpers.readCachedPage(
      key: chaveCacheCompras(_filtro),
      fromMap: CompraModel.fromMap,
      forceRefresh: event.forceRefresh,
    );
    if (cached != null) {
      emit(await _sucesso(cached.itens, cached.numPag, cached.maxPag));
      return;
    }

    if (ListBlocHelpers.shouldShowFullLoading(
      forceRefresh: event.forceRefresh,
      hasVisibleData: temLista,
    )) {
      emit(ComprasLoadingState(filtro: _filtro));
    }

    try {
      final pagina = await listarCompras(
        filtro: _filtro,
        forceRefresh: event.forceRefresh,
      );
      emit(await _sucesso(pagina.itens, pagina.numPag, pagina.maxPag));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(ComprasErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _carregarMais(
    ComprasLoadMoreEvent event,
    Emitter<ComprasState> emit,
  ) async {
    final atual = state;
    if (atual is! ComprasSuccessState ||
        atual.loadingMore ||
        !atual.temProximaPagina) {
      return;
    }
    emit(atual.copyWith(loadingMore: true));
    try {
      final pagina = await listarCompras(
        filtro: _filtro,
        forceRefresh: true,
        pagina: atual.numPag + 1,
      );
      final compras = [...atual.compras, ...pagina.itens];
      emit(
        atual.copyWith(
          compras: compras,
          grupos: montarGruposPorDia(
            compras: compras,
            contasPorId: atual.contasPorId,
            cartoesPorId: atual.cartoesPorId,
          ),
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

  Future<ComprasSuccessState> _sucesso(
    List<CompraModel> compras,
    int numPag,
    int maxPag,
  ) async {
    final contasPorId = await mapearContas();
    final cartoesPorId = await mapearCartoes();
    final categoriasPorId = await mapearCategorias();
    final pendentesMensais = await _gastosPendentesDoDia();
    final pendentesAssinaturas = await _assinaturasPendentesDoDia();
    final pendentesRecebimentos = await _recebimentosPendentesDoDia();
    return ComprasSuccessState(
      compras: compras,
      pendentesMensais: pendentesMensais,
      pendentesAssinaturas: pendentesAssinaturas,
      pendentesRecebimentos: pendentesRecebimentos,
      grupos: montarGruposPorDia(
        compras: compras,
        contasPorId: contasPorId,
        cartoesPorId: cartoesPorId,
      ),
      filtro: _filtro,
      numPag: numPag,
      maxPag: maxPag,
      contasPorId: contasPorId,
      cartoesPorId: cartoesPorId,
      categoriasPorId: categoriasPorId,
    );
  }
}

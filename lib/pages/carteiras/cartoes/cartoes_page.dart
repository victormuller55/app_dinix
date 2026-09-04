import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/await_bloc_refresh.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cadastro_cartao/cadastro_cartao_page.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_bloc.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_event.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_state.dart';
import 'package:app_dinix/pages/carteiras/cartoes/detalhe_cartao/detalhe_cartao_page.dart';
import 'package:app_dinix/widgets/app_error_state.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:app_dinix/widgets/dinix_scaffold.dart';
import 'package:app_dinix/widgets/empty.dart';
import 'package:app_dinix/widgets/lista_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CartoesPage extends StatefulWidget {
  const CartoesPage({super.key});

  @override
  State<CartoesPage> createState() => _CartoesPageState();
}

class _CartoesPageState extends State<CartoesPage> {
  final CartoesBloc bloc = CartoesBloc();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    bloc.add(CartoesLoadEvent());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 120) {
      bloc.add(CartoesLoadMoreEvent());
    }
  }

  Future<void> _abrirCadastro({CartaoCreditoModel? cartao}) async {
    final salvo = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => CadastroCartaoPage(cartao: cartao)),
    );
    if (salvo == true && mounted) {
      bloc.add(CartoesLoadEvent(forceRefresh: true));
    }
  }

  Future<void> _abrirDetalhe(CartaoCreditoModel cartao) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => DetalheCartaoPage(cartao: cartao)),
    );
    if (mounted) {
      bloc.add(CartoesLoadEvent(forceRefresh: true));
    }
  }

  Widget _item(CartaoCreditoModel cartao) {
    final limite = cartao.limite ?? 0;
    final usado = cartao.limiteUsado ?? 0;
    final percentual = limite <= 0 ? 0.0 : (usado / limite).clamp(0.0, 1.0);
    final corBanco = bancoCatalogoDe(cartao.banco, fallback: cartao.nome)
            ?.corColor ??
        DinixColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: () => _abrirDetalhe(cartao),
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    bancoIcon(
                      banco: cartao.banco,
                      fallback: cartao.nome,
                      size: 32,
                    ),
                    appSizedBox(width: AppSpacing.normal),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          appText(
                            cartao.nome ?? '',
                            bold: true,
                            color: DinixColors.textPrimary,
                          ),
                          appText(
                            cartao.banco ?? '',
                            color: DinixColors.textMuted,
                            fontSize: AppFontSizes.verySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                appSizedBox(height: AppSpacing.normal),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentual,
                    minHeight: 6,
                    color: corBanco,
                    backgroundColor: AppColors.grey800,
                  ),
                ),
                appSizedBox(height: AppSpacing.small),
                appText(
                  '${formataMoeda(usado)} de ${formataMoeda(limite)}',
                  color: DinixColors.textMuted,
                  fontSize: AppFontSizes.verySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocBuilder<CartoesBloc, CartoesState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is CartoesLoadingState || state is CartoesInitialState) {
          return appLoadingDinix();
        }
        if (state is CartoesErrorState) {
          return appErrorState(
            errorModel: state.errorModel,
            subtitle:
                state.errorModel.mensagem ?? 'Erro ao carregar cartões.',
            onRetry: () => bloc.add(CartoesLoadEvent(forceRefresh: true)),
          );
        }
        if (state is CartoesSuccessState) {
          Future<void> atualizar() => awaitBlocRefresh(
            bloc,
            isDone: (state) =>
                state is CartoesSuccessState || state is CartoesErrorState,
            dispatch: () => bloc.add(CartoesLoadEvent(forceRefresh: true)),
          );

          if (state.cartoes.isEmpty) {
            return listaRefreshVazia(
              context: context,
              onRefresh: atualizar,
              child: emptyMessage(
                title: 'Nenhum cartão',
                subtitle: 'Cadastre um cartão vinculado a uma conta para compras no crédito.',
                icon: Phosphor.creditCard,
              ),
            );
          }
          return listaRefreshBuilder(
            onRefresh: atualizar,
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: state.cartoes.length + (state.loadingMore ? 1 : 0),
            itemBuilder: (_, index) {
              if (index >= state.cartoes.length) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: appLoadingDinix(size: 24),
                );
              }
              return _item(state.cartoes[index]);
            },
          );
        }
        return appLoadingDinix();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return dinixMenuScaffold(
      title: 'Cartões',
      onAdd: () => _abrirCadastro(),
      addTooltip: 'Novo cartão',
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    bloc.close();
    super.dispose();
  }
}

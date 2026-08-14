import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/bancos_catalogo.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/pages/carteiras/cadastro_conta/cadastro_conta_page.dart';
import 'package:app_dinix/pages/carteiras/carteiras_bloc.dart';
import 'package:app_dinix/pages/carteiras/carteiras_event.dart';
import 'package:app_dinix/pages/carteiras/carteiras_state.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_page.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
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

class CarteirasPage extends StatefulWidget {
  const CarteirasPage({super.key});

  @override
  State<CarteirasPage> createState() => _CarteirasPageState();
}

class _CarteirasPageState extends State<CarteirasPage> {
  final CarteirasBloc bloc = CarteirasBloc();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    bloc.add(CarteirasLoadEvent());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 120) {
      bloc.add(CarteirasLoadMoreEvent());
    }
  }

  Future<void> _abrirCadastro({ContaModel? conta}) async {
    final salvo = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => CadastroContaPage(conta: conta)),
    );
    if (salvo == true && mounted) {
      bloc.add(CarteirasLoadEvent(forceRefresh: true));
    }
  }

  void _abrirCartoes() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => const CartoesPage()),
    );
  }

  double _totalSaldo(List<ContaModel> contas) {
    return contas.fold(
      0.0,
      (sum, conta) => sum + (conta.saldoAtual ?? conta.saldoInicial ?? 0),
    );
  }

  Widget _resumoTotal(double total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            children: [
              appText(
                'Total em contas',
                color: AppColors.grey400,
                fontSize: AppFontSizes.verySmall,
              ),
              appSizedBox(height: 6),
              appText(
                formataMoeda(total),
                bold: true,
                color: DinixColors.textPrimary,
                fontSize: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(ContaModel conta) {
    final cor = corFromHex(conta.cor) ??
        BancosCatalogo.porNome(conta.nomeBanco)?.corColor ??
        DinixColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: () => _abrirCadastro(conta: conta),
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 42,
                  decoration: BoxDecoration(
                    color: cor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                appSizedBox(width: AppSpacing.normal),
                bancoIcon(
                  banco: conta.nomeBanco,
                  fallback: conta.nome,
                  size: 42,
                  gradient: BancosCatalogo.porNome(conta.nomeBanco)?.gradiente,
                ),
                appSizedBox(width: AppSpacing.normal),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      appText(
                        conta.nomeBanco ?? conta.nome ?? '',
                        bold: true,
                        color: DinixColors.textPrimary,
                        fontSize: AppFontSizes.small,
                      ),
                      appText(
                        TipoConta.rotulo(conta.tipoConta),
                        color: AppColors.grey400,
                        fontSize: AppFontSizes.verySmall,
                      ),
                    ],
                  ),
                ),
                appText(
                  formataMoeda(conta.saldoAtual ?? conta.saldoInicial),
                  bold: true,
                  color: DinixColors.textPrimary,
                  fontSize: AppFontSizes.medium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lista(CarteirasSuccessState state) {
    Future<void> atualizar() async {
      bloc.add(CarteirasLoadEvent(forceRefresh: true));
    }

    if (state.contas.isEmpty) {
      return listaRefreshVazia(
        context: context,
        onRefresh: atualizar,
        child: emptyMessage(
          title: 'Nenhuma conta ainda',
          subtitle: 'Cadastre sua primeira conta para começar a lançar gastos.',
          icon: Phosphor.wallet,
        ),
      );
    }

    return listaRefreshBuilder(
      onRefresh: atualizar,
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      itemCount: state.contas.length + 1 + (state.loadingMore ? 1 : 0),
      itemBuilder: (_, index) {
        if (index == 0) return _resumoTotal(_totalSaldo(state.contas));
        final contaIndex = index - 1;
        if (contaIndex >= state.contas.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: appLoadingDinix(size: 24),
          );
        }
        return _item(state.contas[contaIndex]);
      },
    );
  }

  Widget _error(ErrorModel errorModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            appText(
              errorModel.mensagem ?? 'Não foi possível carregar as contas.',
              color: DinixColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            appSizedBox(height: AppSpacing.medium),
            appElevatedButtonDinix(
              title: 'Tentar novamente',
              onTap: () => bloc.add(CarteirasLoadEvent(forceRefresh: true)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocBuilder<CarteirasBloc, CarteirasState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is CarteirasLoadingState || state is CarteirasInitialState) {
          return appLoadingDinix();
        }
        if (state is CarteirasErrorState) return _error(state.errorModel);
        if (state is CarteirasSuccessState) return _lista(state);
        return appLoadingDinix();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return dinixMenuScaffold(
      title: 'Carteiras',
      onAdd: _abrirCadastro,
      addTooltip: 'Nova conta',
      actions: [
        IconButton(
          onPressed: _abrirCartoes,
          icon: const Icon(Phosphor.creditCard, color: DinixColors.primary),
          tooltip: 'Cartões',
        ),
      ],
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

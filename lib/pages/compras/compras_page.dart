import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/await_bloc_refresh.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/categoria_icone.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/compra_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/assinatura_model.dart';
import 'package:app_dinix/models/gasto_mensal_model.dart';
import 'package:app_dinix/models/recebimento_mensal_model.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_service.dart';
import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_page.dart';
import 'package:app_dinix/pages/compras/compras_bloc.dart';
import 'package:app_dinix/pages/compras/compras_event.dart';
import 'package:app_dinix/pages/compras/compras_state.dart';
import 'package:app_dinix/pages/gastos_mensais/gastos_mensais_page.dart';
import 'package:app_dinix/pages/gastos_mensais/gastos_mensais_service.dart';
import 'package:app_dinix/pages/recebimentos_mensais/recebimentos_mensais_service.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_error_state.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_select_sheet.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:app_dinix/widgets/dinix_scaffold.dart';
import 'package:app_dinix/widgets/empty.dart';
import 'package:app_dinix/widgets/lista_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class ComprasPage extends StatefulWidget {
  const ComprasPage({super.key});

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  final ComprasBloc bloc = ComprasBloc();
  final ScrollController _scrollController = ScrollController();
  int _direcaoDia = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 120) {
        bloc.add(ComprasLoadMoreEvent());
      }
    });
    bloc.add(ComprasLoadEvent());
  }

  Future<void> _abrirCadastro({CompraModel? compra}) async {
    final salvo = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => CadastroCompraPage(compra: compra)),
    );
    if (salvo == true && mounted) {
      bloc.add(ComprasLoadEvent(forceRefresh: true));
    }
  }

  Future<void> _abrirGastosMensais() async {
    await Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => const GastosMensaisPage()),
    );
    if (mounted) {
      bloc.add(ComprasLoadEvent(forceRefresh: true));
    }
  }

  Future<void> _pagarPendente({
    required String id,
    required String nome,
    required double? valor,
    required String? formaPadrao,
    required String? idContaPadrao,
    required String? idCartaoPadrao,
    required bool isAssinatura,
    required ComprasSuccessState state,
  }) async {
    final forma = await showAppSelectSheet<String>(
      context: context,
      title: 'Como vai pagar?',
      items: FormaPagamento.valores,
      labelOf: FormaPagamento.rotulo,
      selected: formaPadrao,
    );
    if (forma == null || !mounted) return;

    String? idConta;
    String? idCartao;

    if (FormaPagamento.usaCartao(forma)) {
      final cartoes = state.cartoesPorId.values.toList();
      if (cartoes.isEmpty) {
        showToastWarning(message: 'Cadastre um cartão antes.');
        return;
      }
      final cartao = await showAppSelectSheet<CartaoCreditoModel>(
        context: context,
        title: 'Cartão',
        items: cartoes,
        labelOf: (c) => c.nome ?? '',
        subtitleOf: (c) => c.banco,
        selected: cartoes.where((c) => c.id == idCartaoPadrao).firstOrNull,
        leadingOf: (c) => bancoIcon(banco: c.banco ?? c.nome, size: 32),
      );
      if (cartao == null || cartao.id == null || !mounted) return;
      idCartao = cartao.id;
    } else {
      final contas = state.contasPorId.values.toList();
      if (contas.isEmpty) {
        showToastWarning(message: 'Cadastre uma conta antes.');
        return;
      }
      final conta = await showAppSelectSheet<ContaModel>(
        context: context,
        title: 'Conta',
        items: contas,
        labelOf: (c) => c.nome ?? '',
        subtitleOf: (c) => TipoConta.rotulo(c.tipoConta),
        selected: contas.where((c) => c.id == idContaPadrao).firstOrNull,
        leadingOf: (c) => bancoIcon(banco: c.nomeBanco ?? c.nome, size: 32),
      );
      if (conta == null || conta.id == null || !mounted) return;
      idConta = conta.id;
    }

    final destino = FormaPagamento.usaCartao(forma)
        ? state.cartoesPorId[idCartao]?.nome ?? 'cartão'
        : state.contasPorId[idConta]?.nome ?? 'conta';

    final ok = await showAppConfirmDialog(
      context,
      title: 'Confirmar pagamento',
      message:
          'Registrar ${formataMoeda(valor)} de "$nome" via ${FormaPagamento.rotulo(forma)} ($destino)?',
      confirmLabel: 'Pago',
    );
    if (ok != true || !mounted) return;

    try {
      final data = state.filtro.dataSelecionada;
      final dataIso =
          '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
      if (isAssinatura) {
        await confirmarPagamentoAssinatura(
          id: id,
          formaPagamento: forma,
          idConta: idConta,
          idCartaoCredito: idCartao,
          dataIso: dataIso,
        );
      } else {
        await confirmarPagamentoGastoMensal(
          id: id,
          formaPagamento: forma,
          idConta: idConta,
          idCartaoCredito: idCartao,
          dataIso: dataIso,
        );
      }
      if (!mounted) return;
      showToastSuccess(message: isAssinatura ? 'Assinatura paga' : 'Gasto mensal pago');
      bloc.add(ComprasLoadEvent(forceRefresh: true));
    } catch (e) {
      if (!mounted) return;
      showAppErrorSnackbar(errorModelFromException(e));
    }
  }

  Future<void> _pagarGastoMensal(
    GastoMensalModel gasto,
    ComprasSuccessState state,
  ) async {
    final id = gasto.id;
    if (id == null) return;
    await _pagarPendente(
      id: id,
      nome: gasto.nome ?? '',
      valor: gasto.valor,
      formaPadrao: gasto.formaPagamento,
      idContaPadrao: gasto.idConta,
      idCartaoPadrao: gasto.idCartaoCredito,
      isAssinatura: false,
      state: state,
    );
  }

  Future<void> _pagarAssinatura(
    AssinaturaModel assinatura,
    ComprasSuccessState state,
  ) async {
    final id = assinatura.id;
    if (id == null) return;
    await _pagarPendente(
      id: id,
      nome: assinatura.nome ?? '',
      valor: assinatura.valor,
      formaPadrao: assinatura.formaPagamento,
      idContaPadrao: assinatura.idConta,
      idCartaoPadrao: assinatura.idCartaoCredito,
      isAssinatura: true,
      state: state,
    );
  }

  Future<void> _receberRecebimentoMensal(
    RecebimentoMensalModel item,
    ComprasSuccessState state,
  ) async {
    final id = item.id;
    if (id == null) return;

    String? idConta = item.idConta;
    if (idConta == null || idConta.isEmpty) {
      final contas = state.contasPorId.values.toList();
      if (contas.isEmpty) {
        showToastWarning(message: 'Cadastre uma conta antes.');
        return;
      }
      final selecionada = await showAppSelectSheet<ContaModel>(
        context: context,
        title: 'Conta de destino',
        items: contas,
        labelOf: (c) => c.nome ?? 'Conta',
        subtitleOf: (c) => TipoConta.rotulo(c.tipoConta),
        selected: null,
        leadingOf: (c) => bancoIcon(banco: c.nomeBanco ?? c.nome, size: 32),
      );
      if (selecionada == null) return;
      idConta = selecionada.id;
    }
    if (idConta == null || idConta.isEmpty) return;
    if (!mounted) return;

    final ok = await showAppConfirmDialog(
      context,
      title: 'Confirmar recebimento',
      message:
          'Marcar "${item.nome ?? ''}" (${formataMoeda(item.valor)}) como recebido?',
      confirmLabel: 'Recebido',
      icon: Phosphor.trendUp,
    );
    if (ok != true || !mounted) return;

    try {
      final data = state.filtro.dataSelecionada;
      final dataIso =
          '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
      await confirmarRecebimentoMensal(
        id: id,
        idConta: idConta,
        dataIso: dataIso,
      );
      if (!mounted) return;
      showToastSuccess(message: 'Recebimento confirmado');
      bloc.add(ComprasLoadEvent(forceRefresh: true));
    } catch (e) {
      if (!mounted) return;
      showAppErrorSnackbar(errorModelFromException(e));
    }
  }

  void _irDia(FiltroCompras atual, int delta) {
    setState(() => _direcaoDia = delta);
    final alvo = atual.dataSelecionada.add(Duration(days: delta));
    bloc.add(ComprasAlterarFiltroEvent(FiltroCompras.dia(alvo)));
  }

  Widget _rotuloDiaAnimado(String rotulo) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final entrando = child.key == ValueKey(rotulo);
        final inicio = Offset(
          entrando ? _direcaoDia * 0.45 : -_direcaoDia * 0.45,
          0,
        );
        final deslize =
            Tween<Offset>(begin: inicio, end: Offset.zero).animate(animation);
        return ClipRect(
          child: SlideTransition(
            position: deslize,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
      child: SizedBox(
        key: ValueKey(rotulo),
        width: double.infinity,
        child: appText(
          rotulo,
          bold: true,
          color: DinixColors.textPrimary,
          fontSize: AppFontSizes.normal,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _filtro(FiltroCompras filtro) {
    final rotulo = rotuloDiaNavegacao(filtro.dataSelecionada);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _irDia(filtro, -1),
            icon: Icon(Phosphor.caretLeft, color: DinixColors.textPrimary),
            tooltip: 'Dia anterior',
          ),
          Expanded(child: _rotuloDiaAnimado(rotulo)),
          IconButton(
            onPressed: () => _irDia(filtro, 1),
            icon: Icon(Phosphor.caretRight, color: DinixColors.textPrimary),
            tooltip: 'Próximo dia',
          ),
        ],
      ),
    );
  }

  Widget _resumoDia(GrupoDiaCompras grupo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: appContainer(
        padding: const EdgeInsets.all(16),
        backgroundColor: DinixColors.surfaceElevated,
        radius: BorderRadius.circular(AppRadius.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appText(
              rotuloDiaRelativo(grupo.dataIso),
              color: DinixColors.textMuted,
              fontSize: AppFontSizes.verySmall,
            ),
            appSizedBox(height: AppSpacing.small),
            appText(
              formataMoeda(grupo.total),
              bold: true,
              color: DinixColors.primary,
              fontSize: AppFontSizes.big,
            ),
            if (grupo.porBanco.isNotEmpty) ...[
              appSizedBox(height: AppSpacing.normal),
              Divider(color: AppColors.grey800, height: 1),
              appSizedBox(height: AppSpacing.normal),
              ...grupo.porBanco.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      bancoIcon(banco: item.banco, size: 18),
                      appSizedBox(width: AppSpacing.normal),
                      Expanded(
                        child: appText(
                          item.banco,
                          color: DinixColors.textPrimary,
                          fontSize: AppFontSizes.small,
                        ),
                      ),
                      appText(
                        formataMoeda(item.valor),
                        bold: true,
                        color: DinixColors.textPrimary,
                        fontSize: AppFontSizes.small,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _itemPendente({
    required String nome,
    required double? valor,
    required String subtitulo,
    required IconData icone,
    required VoidCallback onPagar,
    String botaoLabel = 'Pago',
    Color valorCor = const Color(0xFFEF5350),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DinixColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: DinixColors.primary, size: 22),
              ),
              appSizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appText(
                      nome,
                      bold: true,
                      color: DinixColors.textPrimary,
                      fontSize: AppFontSizes.small,
                    ),
                    appText(
                      subtitulo,
                      color: DinixColors.textMuted,
                      fontSize: AppFontSizes.verySmall,
                    ),
                    appSizedBox(height: 2),
                    appText(
                      formataMoeda(valor),
                      bold: true,
                      color: valorCor,
                      fontSize: AppFontSizes.small,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onPagar,
                style: TextButton.styleFrom(
                  foregroundColor: DinixColors.primary,
                ),
                child: appText(
                  botaoLabel,
                  bold: true,
                  color: DinixColors.primary,
                  fontSize: AppFontSizes.small,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(CompraModel compra, Map<String, CategoriaModel> categoriasPorId) {
    final categoria = categoriasPorId[compra.idCategoria ?? ''];
    final icone =
        iconeDaCategoria(categoria, categoriasPorId: categoriasPorId);
    final hora = formataHora(compra.horaCompra);
    final detalhes = [
      if (hora.isNotEmpty) hora,
      FormaPagamento.rotulo(compra.formaPagamento),
      if ((compra.qtdParcelas ?? 1) > 1) '${compra.qtdParcelas}x',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: ListTile(
          onTap: () => _abrirCadastro(compra: compra),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DinixColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: DinixColors.primary, size: 22),
          ),
          title: appText(
            compra.descricao ?? '',
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: AppFontSizes.small,
          ),
          subtitle: appText(
            detalhes,
            color: DinixColors.textMuted,
            fontSize: AppFontSizes.verySmall,
          ),
          trailing: appText(
            formataMoeda(compra.valorTotal),
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: AppFontSizes.normal,
          ),
        ),
      ),
    );
  }

  List<Widget> _linhas(ComprasSuccessState state) {
    final widgets = <Widget>[_filtro(state.filtro)];
    for (final pendente in state.pendentesRecebimentos) {
      widgets.add(
        _itemPendente(
          nome: pendente.nome ?? '',
          valor: pendente.valor,
          subtitulo: 'Recebimento mensal · pendente',
          icone: Phosphor.trendUp,
          botaoLabel: 'Recebido',
          valorCor: const Color(0xFF4CAF50),
          onPagar: () => _receberRecebimentoMensal(pendente, state),
        ),
      );
    }
    for (final pendente in state.pendentesAssinaturas) {
      widgets.add(
        _itemPendente(
          nome: pendente.nome ?? '',
          valor: pendente.valor,
          subtitulo: 'Assinatura · pendente',
          icone: Phosphor.stack,
          onPagar: () => _pagarAssinatura(pendente, state),
        ),
      );
    }
    for (final pendente in state.pendentesMensais) {
      widgets.add(
        _itemPendente(
          nome: pendente.nome ?? '',
          valor: pendente.valor,
          subtitulo: 'Gasto mensal · pendente',
          icone: Phosphor.calendarBlank,
          onPagar: () => _pagarGastoMensal(pendente, state),
        ),
      );
    }
    for (final grupo in state.grupos) {
      widgets.add(_resumoDia(grupo));
      for (final compra in grupo.compras) {
        widgets.add(_item(compra, state.categoriasPorId));
      }
    }
    if (state.loadingMore) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(child: appLoadingDinix(size: 22)),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return dinixMenuScaffold(
      title: 'Compras',
      actions: [
        IconButton(
          onPressed: _abrirGastosMensais,
          tooltip: 'Gastos mensais',
          icon: Icon(
            Phosphor.calendarBlank,
            color: DinixColors.appBarIcon,
            size: 24,
          ),
        ),
      ],
      onAdd: () => _abrirCadastro(),
      addTooltip: 'Nova compra',
      body: BlocBuilder<ComprasBloc, ComprasState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is ComprasLoadingState || state is ComprasInitialState) {
            final filtro = state is ComprasLoadingState ? state.filtro : null;
            if (filtro != null) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: _filtro(filtro),
                  ),
                  Expanded(child: appLoadingDinix()),
                ],
              );
            }
            return appLoadingDinix();
          }
          if (state is ComprasErrorState) {
            return appErrorState(
              errorModel: state.errorModel,
              subtitle: state.errorModel.mensagem ??
                  'Não foi possível carregar as compras.',
              onRetry: () => bloc.add(ComprasLoadEvent(forceRefresh: true)),
            );
          }
          if (state is ComprasSuccessState) {
            Future<void> atualizar() => awaitBlocRefresh(
              bloc,
              isDone: (state) =>
                  state is ComprasSuccessState || state is ComprasErrorState,
              dispatch: () => bloc.add(ComprasLoadEvent(forceRefresh: true)),
            );
            final vazio = state.compras.isEmpty &&
                state.pendentesMensais.isEmpty &&
                state.pendentesAssinaturas.isEmpty &&
                state.pendentesRecebimentos.isEmpty;
            if (vazio) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: _filtro(state.filtro),
                  ),
                  Expanded(
                    child: listaRefreshVazia(
                      context: context,
                      onRefresh: atualizar,
                      child: emptyMessage(
                        title: 'Nenhuma compra',
                        subtitle: 'Lance Pix, débito ou crédito neste dia.',
                        icon: Phosphor.shoppingBag,
                      ),
                    ),
                  ),
                ],
              );
            }
            final linhas = _linhas(state);
            return listaRefreshBuilder(
              onRefresh: atualizar,
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
              itemCount: linhas.length,
              itemBuilder: (_, i) => linhas[i],
            );
          }
          return appLoadingDinix();
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    bloc.close();
    super.dispose();
  }
}

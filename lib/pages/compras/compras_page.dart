import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/categoria_icone.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/compra_model.dart';
import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_page.dart';
import 'package:app_dinix/pages/compras/compras_bloc.dart';
import 'package:app_dinix/pages/compras/compras_event.dart';
import 'package:app_dinix/pages/compras/compras_state.dart';
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
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 120) {
        bloc.add(ComprasLoadMoreEvent());
      }
    });
    bloc.add(ComprasLoadEvent());
  }

  Future<void> _abrirCadastro({CompraModel? compra}) async {
    final salvo = await Navigator.of(
      context,
    ).push<bool>(CupertinoPageRoute(builder: (_) => CadastroCompraPage(compra: compra)));
    if (salvo == true && mounted) {
      bloc.add(ComprasLoadEvent(forceRefresh: true));
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
        final deslize = Tween<Offset>(begin: inicio, end: Offset.zero).animate(animation);
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
              color: AppColors.grey400,
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

  Widget _item(CompraModel compra, Map<String, CategoriaModel> categoriasPorId) {
    final categoria = categoriasPorId[compra.idCategoria ?? ''];
    final icone = iconeDaCategoria(categoria, categoriasPorId: categoriasPorId);
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
          subtitle: appText(detalhes, color: AppColors.grey400, fontSize: AppFontSizes.verySmall),
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
            return Center(
              child: appElevatedButtonDinix(
                title: 'Tentar novamente',
                onTap: () => bloc.add(ComprasLoadEvent(forceRefresh: true)),
              ),
            );
          }
          if (state is ComprasSuccessState) {
            Future<void> atualizar() async {
              bloc.add(ComprasLoadEvent(forceRefresh: true));
            }
            if (state.compras.isEmpty) {
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

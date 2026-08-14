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

const _meses = [
  '',
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

class ComprasPage extends StatefulWidget {
  const ComprasPage({super.key});

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  final ComprasBloc bloc = ComprasBloc();
  final ScrollController _scrollController = ScrollController();

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

  void _irMes(FiltroCompras atual, int delta) {
    final competencia = DateTime(atual.ano, atual.mes + delta);
    bloc.add(
      ComprasAlterarFiltroEvent(FiltroCompras(mes: competencia.month, ano: competencia.year)),
    );
  }

  Future<void> _escolherDias(FiltroCompras atual) async {
    final escolhidos = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DinixColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      builder: (ctx) => _CalendarioDiasSheet(
        mes: atual.mes,
        ano: atual.ano,
        selecionados: atual.mesInteiro ? const [] : atual.diasIso,
      ),
    );
    if (escolhidos == null || !mounted) return;
    if (escolhidos.isEmpty) {
      bloc.add(ComprasAlterarFiltroEvent(FiltroCompras(mes: atual.mes, ano: atual.ano)));
      return;
    }
    bloc.add(
      ComprasAlterarFiltroEvent(
        FiltroCompras(mes: atual.mes, ano: atual.ano, mesInteiro: false, diasIso: escolhidos),
      ),
    );
  }

  Widget _chip({required String label, required bool selecionado, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? DinixColors.primary : DinixColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selecionado ? DinixColors.primary : AppColors.grey800),
        ),
        child: appText(
          label,
          bold: selecionado,
          color: selecionado ? Colors.black : DinixColors.textPrimary,
          fontSize: AppFontSizes.verySmall,
        ),
      ),
    );
  }

  Widget _filtro(FiltroCompras filtro) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _irMes(filtro, -1),
                icon: Icon(Phosphor.caretLeft, color: DinixColors.textPrimary),
              ),
              Expanded(
                child: Center(
                  child: appText(
                    '${_meses[filtro.mes]} ${filtro.ano}',
                    bold: true,
                    color: DinixColors.textPrimary,
                    fontSize: AppFontSizes.normal,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _irMes(filtro, 1),
                icon: Icon(Phosphor.caretRight, color: DinixColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip(
                  label: 'Mês inteiro',
                  selecionado: filtro.mesInteiro,
                  onTap: () {
                    if (filtro.mesInteiro) return;
                    bloc.add(
                      ComprasAlterarFiltroEvent(FiltroCompras(mes: filtro.mes, ano: filtro.ano)),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _chip(
                  label: 'Hoje',
                  selecionado: filtro.soHoje,
                  onTap: () => bloc.add(ComprasAlterarFiltroEvent(FiltroCompras.hoje())),
                ),
                const SizedBox(width: 8),
                _chip(
                  label: 'Escolher dias',
                  selecionado: !filtro.mesInteiro && !filtro.soHoje,
                  onTap: () => _escolherDias(filtro),
                ),
              ],
            ),
          ),
          if (!filtro.mesInteiro && filtro.diasIso.isNotEmpty) ...[
            appSizedBox(height: AppSpacing.normal),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final dia in filtro.diasIso)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: DinixColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: appText(
                      isoParaBr(dia),
                      color: DinixColors.textMuted,
                      fontSize: AppFontSizes.verySmall,
                    ),
                  ),
              ],
            ),
          ],
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
                        subtitle: state.filtro.mesInteiro
                            ? 'Lance Pix, débito ou crédito neste mês.'
                            : 'Não há lançamentos nos dias selecionados.',
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

class _CalendarioDiasSheet extends StatefulWidget {
  final int mes;
  final int ano;
  final List<String> selecionados;

  const _CalendarioDiasSheet({required this.mes, required this.ano, required this.selecionados});

  @override
  State<_CalendarioDiasSheet> createState() => _CalendarioDiasSheetState();
}

class _CalendarioDiasSheetState extends State<_CalendarioDiasSheet> {
  late final Set<String> _selecionados;

  @override
  void initState() {
    super.initState();
    _selecionados = {...widget.selecionados};
  }

  String _iso(int dia) {
    return '${widget.ano}-${widget.mes.toString().padLeft(2, '0')}-${dia.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final primeiro = DateTime(widget.ano, widget.mes, 1);
    final diasNoMes = DateTime(widget.ano, widget.mes + 1, 0).day;
    final offset = primeiro.weekday % 7;
    final hojeIso = dataHojeIso();
    const labels = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            appText(
              'Escolher dias · ${_meses[widget.mes]}',
              bold: true,
              color: DinixColors.textPrimary,
              fontSize: AppFontSizes.normal,
            ),
            appSizedBox(height: AppSpacing.medium),
            Row(
              children: [
                for (final label in labels)
                  Expanded(
                    child: Center(
                      child: appText(
                        label,
                        color: AppColors.grey400,
                        fontSize: AppFontSizes.verySmall,
                      ),
                    ),
                  ),
              ],
            ),
            appSizedBox(height: AppSpacing.small),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: offset + diasNoMes,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (_, index) {
                if (index < offset) return const SizedBox.shrink();
                final dia = index - offset + 1;
                final iso = _iso(dia);
                final marcado = _selecionados.contains(iso);
                final ehHoje = iso == hojeIso;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (marcado) {
                        _selecionados.remove(iso);
                      } else {
                        _selecionados.add(iso);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: marcado ? DinixColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: ehHoje && !marcado ? Border.all(color: DinixColors.primary) : null,
                    ),
                    alignment: Alignment.center,
                    child: appText(
                      '$dia',
                      bold: marcado || ehHoje,
                      color: marcado ? Colors.black : DinixColors.textPrimary,
                      fontSize: AppFontSizes.small,
                    ),
                  ),
                );
              },
            ),
            appSizedBox(height: AppSpacing.medium),
            Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      return appElevatedButtonDinix(
                        title: 'Mês inteiro',
                        invertedStyle: true,
                        enableEffects: false,
                        width: constraints.maxWidth,
                        onTap: () => Navigator.of(context).pop(<String>[]),
                        height: 48,
                      );
                    },
                  ),
                ),
                appSizedBox(width: AppSpacing.normal),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      return appElevatedButtonDinix(
                        title: 'Aplicar',
                        width: constraints.maxWidth,
                        onTap: () {
                          final dias = _selecionados.toList()..sort();
                          Navigator.of(context).pop(dias);
                        },
                        height: 48,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

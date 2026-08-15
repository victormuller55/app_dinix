import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/receita_model.dart';
import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_page.dart';
import 'package:app_dinix/pages/receitas/receitas_bloc.dart';
import 'package:app_dinix/pages/receitas/receitas_event.dart';
import 'package:app_dinix/pages/receitas/receitas_state.dart';
import 'package:app_dinix/widgets/app_error_state.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/dinix_scaffold.dart';
import 'package:app_dinix/widgets/empty.dart';
import 'package:app_dinix/widgets/lista_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class ReceitasPage extends StatefulWidget {
  final bool isMenuTab;

  const ReceitasPage({super.key, this.isMenuTab = false});

  @override
  State<ReceitasPage> createState() => _ReceitasPageState();
}

class _ReceitasPageState extends State<ReceitasPage> {
  final ReceitasBloc bloc = ReceitasBloc();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 120) {
        bloc.add(ReceitasLoadMoreEvent());
      }
    });
    bloc.add(ReceitasLoadEvent());
  }

  Future<void> _abrirCadastro({ReceitaModel? receita}) async {
    final salvo = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => CadastroReceitaPage(receita: receita)),
    );
    if (salvo == true && mounted) {
      bloc.add(ReceitasLoadEvent(forceRefresh: true));
    }
  }

  String _nomeConta(ReceitaModel receita, Map<String, ContaModel> contas) {
    final conta = contas[receita.idConta ?? ''];
    return conta?.nomeBanco ?? conta?.nome ?? 'Conta';
  }

  String _nomeOrigem(ReceitaModel receita, Map<String, CategoriaModel> categorias) {
    final categoria = categorias[receita.idCategoria ?? ''];
    return categoria?.nome ?? receita.descricao ?? 'Ganho';
  }

  Widget _resumoDia(ResumoDiaReceitas resumo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: appContainer(
        padding: const EdgeInsets.all(16),
        backgroundColor: DinixColors.surfaceElevated,
        radius: BorderRadius.circular(AppRadius.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appText(
              'Hoje · ${isoParaBr(resumo.dataIso)}',
              color: AppColors.grey400,
              fontSize: AppFontSizes.verySmall,
            ),
            appSizedBox(height: AppSpacing.small),
            appText(
              formataMoeda(resumo.total),
              bold: true,
              color: const Color(0xFF4CAF50),
              fontSize: AppFontSizes.big,
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    ReceitaModel receita,
    Map<String, ContaModel> contas,
    Map<String, CategoriaModel> categorias,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: ListTile(
          onTap: () => _abrirCadastro(receita: receita),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF1B5E20),
            child: Icon(Phosphor.arrowDown, color: const Color(0xFF4CAF50), size: 20),
          ),
          title: appText(
            receita.descricao?.isNotEmpty == true ? receita.descricao! : _nomeOrigem(receita, categorias),
            bold: true,
            color: DinixColors.textPrimary,
          ),
          subtitle: appText(
            '${isoParaBr(receita.dataRecebimento)} · ${_nomeOrigem(receita, categorias)} · ${_nomeConta(receita, contas)}',
            color: AppColors.grey400,
            fontSize: AppFontSizes.verySmall,
          ),
          trailing: appText(
            formataMoeda(receita.valor),
            bold: true,
            color: const Color(0xFF4CAF50),
          ),
        ),
      ),
    );
  }

  Widget _lista(ReceitasSuccessState state) {
    Future<void> atualizar() async {
      bloc.add(ReceitasLoadEvent(forceRefresh: true));
    }

    if (state.receitas.isEmpty) {
      return listaRefreshVazia(
        context: context,
        onRefresh: atualizar,
        child: emptyMessage(
          title: 'Nenhuma entrada',
          subtitle: 'Cadastre salários, freelances e outros recebimentos.',
          icon: Phosphor.money,
        ),
      );
    }

    return listaRefreshBuilder(
      onRefresh: atualizar,
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: state.receitas.length + 1 + (state.loadingMore ? 1 : 0),
      itemBuilder: (_, index) {
        if (index == 0) return _resumoDia(state.resumoDia);
        final receitaIndex = index - 1;
        if (receitaIndex >= state.receitas.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: appLoadingDinix(size: 24),
          );
        }
        return _item(
          state.receitas[receitaIndex],
          state.contasPorId,
          state.categoriasPorId,
        );
      },
    );
  }

  Widget _error(ErrorModel errorModel) {
    return appErrorState(
      errorModel: errorModel,
      subtitle: errorModel.mensagem ?? 'Não foi possível carregar as entradas.',
      onRetry: () => bloc.add(ReceitasLoadEvent(forceRefresh: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = BlocBuilder<ReceitasBloc, ReceitasState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is ReceitasLoadingState || state is ReceitasInitialState) {
          return appLoadingDinix();
        }
        if (state is ReceitasErrorState) return _error(state.errorModel);
        if (state is ReceitasSuccessState) return _lista(state);
        return appLoadingDinix();
      },
    );

    if (widget.isMenuTab) {
      return dinixMenuScaffold(
        title: 'Entradas',
        onAdd: () => _abrirCadastro(),
        addTooltip: 'Nova entrada',
        body: body,
      );
    }

    return scaffold(
      title: 'Entradas',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      drawerColor: DinixColors.textPrimary,
      actions: [dinixAddAction(onTap: _abrirCadastro, tooltip: 'Nova entrada')],
      body: body,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    bloc.close();
    super.dispose();
  }
}

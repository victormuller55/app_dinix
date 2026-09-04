import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/await_bloc_refresh.dart';
import 'package:app_dinix/function/categoria_icone.dart';
import 'package:app_dinix/models/local_model.dart';
import 'package:app_dinix/pages/locais/cadastro_local/cadastro_local_page.dart';
import 'package:app_dinix/pages/locais/locais_bloc.dart';
import 'package:app_dinix/pages/locais/locais_event.dart';
import 'package:app_dinix/pages/locais/locais_state.dart';
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

class LocaisPage extends StatefulWidget {
  const LocaisPage({super.key});

  @override
  State<LocaisPage> createState() => _LocaisPageState();
}

class _LocaisPageState extends State<LocaisPage> {
  final LocaisBloc bloc = LocaisBloc();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 120) {
        bloc.add(LocaisLoadMoreEvent());
      }
    });
    bloc.add(LocaisLoadEvent());
  }

  Future<void> _abrirCadastro({LocalModel? local}) async {
    final salvo = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => CadastroLocalPage(local: local)),
    );
    if (salvo == true && mounted) {
      bloc.add(LocaisLoadEvent(forceRefresh: true));
    }
  }

  Widget _item(LocalModel local) {
    final icone = (local.nomeCategoria == null || local.nomeCategoria!.isEmpty)
        ? Phosphor.storefront
        : iconeCategoria(nome: local.nomeCategoria);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: ListTile(
          onTap: () => _abrirCadastro(local: local),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DinixColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: DinixColors.primary, size: 22),
          ),
          title: appText(local.nome ?? '', bold: true, color: DinixColors.textPrimary),
          subtitle: appText(
            local.nomeCategoria ?? local.descricao ?? '',
            color: DinixColors.textMuted,
            fontSize: AppFontSizes.verySmall,
          ),
          trailing: Icon(Phosphor.caretRight, color: DinixColors.textMuted),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return dinixMenuScaffold(
      title: 'Estabelecimentos',
      onAdd: () => _abrirCadastro(),
      addTooltip: 'Novo local',
      body: BlocBuilder<LocaisBloc, LocaisState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is LocaisLoadingState || state is LocaisInitialState) {
            return appLoadingDinix();
          }
          if (state is LocaisErrorState) {
            return appErrorState(
              errorModel: state.errorModel,
              subtitle: state.errorModel.mensagem ??
                  'Não foi possível carregar os estabelecimentos.',
              onRetry: () => bloc.add(LocaisLoadEvent(forceRefresh: true)),
            );
          }
          if (state is LocaisSuccessState) {
            Future<void> atualizar() => awaitBlocRefresh(
              bloc,
              isDone: (state) =>
                  state is LocaisSuccessState || state is LocaisErrorState,
              dispatch: () => bloc.add(LocaisLoadEvent(forceRefresh: true)),
            );

            if (state.locais.isEmpty) {
              return listaRefreshVazia(
                context: context,
                onRefresh: atualizar,
                child: emptyMessage(
                  title: 'Nenhum estabelecimento',
                  subtitle: 'Cadastre mercados, postos e lojas para usar nas compras.',
                  icon: Phosphor.storefront,
                ),
              );
            }
            return listaRefreshBuilder(
              onRefresh: atualizar,
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: state.locais.length,
              itemBuilder: (_, i) => _item(state.locais[i]),
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

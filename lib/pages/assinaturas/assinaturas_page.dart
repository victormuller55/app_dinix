import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/models/assinatura_model.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_bloc.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_event.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_state.dart';
import 'package:app_dinix/pages/assinaturas/cadastro_assinatura/cadastro_assinatura_page.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/dinix_add_fab.dart';
import 'package:app_dinix/widgets/empty.dart';
import 'package:app_dinix/widgets/lista_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class AssinaturasPage extends StatefulWidget {
  final bool isActive;

  const AssinaturasPage({super.key, this.isActive = true});

  @override
  State<AssinaturasPage> createState() => _AssinaturasPageState();
}

class _AssinaturasPageState extends State<AssinaturasPage> {
  final AssinaturasBloc bloc = AssinaturasBloc();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 120) {
        bloc.add(AssinaturasLoadMoreEvent());
      }
    });
    bloc.add(AssinaturasLoadEvent());
  }

  @override
  void didUpdateWidget(covariant AssinaturasPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      bloc.add(AssinaturasLoadEvent());
    }
  }

  Future<void> _abrirCadastro({AssinaturaModel? assinatura}) async {
    final salvo = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => CadastroAssinaturaPage(assinatura: assinatura)),
    );
    if (salvo == true && mounted) {
      bloc.add(AssinaturasLoadEvent(forceRefresh: true));
    }
  }

  Widget _item(AssinaturaModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: ListTile(
          onTap: () => _abrirCadastro(assinatura: item),
          title: appText(item.nome ?? '', bold: true, color: DinixColors.textPrimary),
          subtitle: appText(
            item.dataProximaCobranca != null
                ? 'Próxima: ${isoParaBr(item.dataProximaCobranca)}'
                : 'Dia ${item.diaCobranca ?? '-'}',
            color: AppColors.grey400,
            fontSize: AppFontSizes.verySmall,
          ),
          trailing: appText(
            formataMoeda(item.valor),
            bold: true,
            color: DinixColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Assinaturas',
      centerTitle: true,
      hideBackIcon: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      drawerColor: DinixColors.textPrimary,
      floatingActionButton: dinixAddFab(label: 'Assinatura', onTap: _abrirCadastro),
      body: BlocBuilder<AssinaturasBloc, AssinaturasState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is AssinaturasLoadingState || state is AssinaturasInitialState) {
            return appLoadingDinix();
          }
          if (state is AssinaturasErrorState) {
            return Center(
              child: appElevatedButtonDinix(
                title: 'Tentar novamente',
                onTap: () => bloc.add(AssinaturasLoadEvent(forceRefresh: true)),
              ),
            );
          }
          if (state is AssinaturasSuccessState) {
            Future<void> atualizar() async {
              bloc.add(AssinaturasLoadEvent(forceRefresh: true));
            }

            if (state.assinaturas.isEmpty) {
              return listaRefreshVazia(
                context: context,
                onRefresh: atualizar,
                child: emptyMessage(
                  title: 'Nenhuma assinatura',
                  subtitle: 'Cadastre Netflix, academia e outros pagamentos recorrentes.',
                  icon: Phosphor.stack,
                ),
              );
            }
            return listaRefreshBuilder(
              onRefresh: atualizar,
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
              itemCount: state.assinaturas.length,
              itemBuilder: (_, i) => _item(state.assinaturas[i]),
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

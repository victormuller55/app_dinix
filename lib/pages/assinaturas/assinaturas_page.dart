import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/categoria_icone.dart';
import 'package:app_dinix/models/assinatura_model.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_bloc.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_event.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_state.dart';
import 'package:app_dinix/pages/assinaturas/cadastro_assinatura/cadastro_assinatura_page.dart';
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

class _TipoAssinatura {
  final String nome;
  final IconData icone;
  final double valor;

  const _TipoAssinatura({
    required this.nome,
    required this.icone,
    required this.valor,
  });
}

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
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 120) {
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

  double _valorMensal(AssinaturaModel item) {
    final valor = item.valor ?? 0;
    switch (item.recorrencia) {
      case Recorrencia.anual:
        return valor / 12;
      case Recorrencia.semanal:
        return valor * 52 / 12;
      default:
        return valor;
    }
  }

  CategoriaModel? _categoriaTipo(
    AssinaturaModel item,
    Map<String, CategoriaModel> categoriasPorId,
  ) {
    final categoria = categoriasPorId[item.idCategoria ?? ''];
    if (categoria == null) return null;
    final idPai = categoria.idCategoriaPai;
    if (idPai != null && idPai.isNotEmpty) {
      return categoriasPorId[idPai] ?? categoria;
    }
    return categoria;
  }

  List<_TipoAssinatura> _porTipo(
    List<AssinaturaModel> assinaturas,
    Map<String, CategoriaModel> categoriasPorId,
  ) {
    final mapa = <String, _TipoAssinatura>{};
    for (final item in assinaturas) {
      if (item.canceladoEm != null && item.canceladoEm!.isNotEmpty) continue;
      final tipo = _categoriaTipo(item, categoriasPorId);
      final nome = (tipo?.nome?.trim().isNotEmpty ?? false) ? tipo!.nome!.trim() : 'Outros';
      final icone = iconeDaCategoria(tipo, categoriasPorId: categoriasPorId);
      final atual = mapa[nome];
      final valor = (atual?.valor ?? 0) + _valorMensal(item);
      mapa[nome] = _TipoAssinatura(nome: nome, icone: icone, valor: valor);
    }
    final lista = mapa.values.toList()
      ..sort((a, b) => b.valor.compareTo(a.valor));
    return lista;
  }

  double _totalMensal(List<AssinaturaModel> assinaturas) {
    return assinaturas
        .where((a) => a.canceladoEm == null || a.canceladoEm!.isEmpty)
        .fold<double>(0, (acc, item) => acc + _valorMensal(item));
  }

  Widget _resumo(
    List<AssinaturaModel> assinaturas,
    Map<String, CategoriaModel> categoriasPorId,
  ) {
    final total = _totalMensal(assinaturas);
    final tipos = _porTipo(assinaturas, categoriasPorId);
    final qtd = assinaturas
        .where((a) => a.canceladoEm == null || a.canceladoEm!.isEmpty)
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: appContainer(
        padding: const EdgeInsets.all(16),
        backgroundColor: DinixColors.surfaceElevated,
        radius: BorderRadius.circular(AppRadius.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appText(
              qtd == 1 ? '1 assinatura ativa' : '$qtd assinaturas ativas',
              color: DinixColors.textMuted,
              fontSize: AppFontSizes.verySmall,
            ),
            appSizedBox(height: AppSpacing.small),
            appText(
              formataMoeda(total),
              bold: true,
              color: DinixColors.primary,
              fontSize: AppFontSizes.big,
            ),
            appText(
              'Total mensal',
              color: DinixColors.textMuted,
              fontSize: AppFontSizes.verySmall,
            ),
            if (tipos.isNotEmpty) ...[
              appSizedBox(height: AppSpacing.normal),
              Divider(color: AppColors.grey800, height: 1),
              appSizedBox(height: AppSpacing.normal),
              ...tipos.map((tipo) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: DinixColors.primary.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(tipo.icone, color: DinixColors.primary, size: 16),
                      ),
                      appSizedBox(width: AppSpacing.normal),
                      Expanded(
                        child: appText(
                          tipo.nome,
                          color: DinixColors.textPrimary,
                          fontSize: AppFontSizes.small,
                        ),
                      ),
                      appText(
                        formataMoeda(tipo.valor),
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

  Widget _item(AssinaturaModel item, Map<String, CategoriaModel> categoriasPorId) {
    final categoria = categoriasPorId[item.idCategoria ?? ''];
    final icone = iconeDaCategoria(categoria, categoriasPorId: categoriasPorId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: ListTile(
          onTap: () => _abrirCadastro(assinatura: item),
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
            item.nome ?? '',
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: AppFontSizes.normal,
          ),
          subtitle: appText(
            item.dataProximaCobranca != null
                ? 'Próxima: ${isoParaBr(item.dataProximaCobranca)}'
                : 'Dia ${item.diaCobranca ?? '-'}',
            color: DinixColors.textMuted,
            fontSize: AppFontSizes.verySmall,
          ),
          trailing: appText(
            formataMoeda(item.valor),
            bold: true,
            color: DinixColors.primary,
            fontSize: AppFontSizes.normal,
          ),
        ),
      ),
    );
  }

  List<Widget> _linhas(AssinaturasSuccessState state) {
    return [
      _resumo(state.assinaturas, state.categoriasPorId),
      ...state.assinaturas.map((item) => _item(item, state.categoriasPorId)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return dinixMenuScaffold(
      title: 'Assinaturas',
      onAdd: () => _abrirCadastro(),
      addTooltip: 'Nova assinatura',
      body: BlocBuilder<AssinaturasBloc, AssinaturasState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is AssinaturasLoadingState || state is AssinaturasInitialState) {
            return appLoadingDinix();
          }
          if (state is AssinaturasErrorState) {
            return appErrorState(
              errorModel: state.errorModel,
              subtitle: state.errorModel.mensagem ??
                  'Não foi possível carregar as assinaturas.',
              onRetry: () =>
                  bloc.add(AssinaturasLoadEvent(forceRefresh: true)),
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

            final linhas = _linhas(state);
            return listaRefreshBuilder(
              onRefresh: atualizar,
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
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

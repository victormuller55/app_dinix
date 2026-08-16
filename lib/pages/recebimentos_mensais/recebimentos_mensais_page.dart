import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/models/recebimento_mensal_model.dart';
import 'package:app_dinix/pages/recebimentos_mensais/cadastro_recebimento_mensal_page.dart';
import 'package:app_dinix/pages/recebimentos_mensais/recebimentos_mensais_service.dart';
import 'package:app_dinix/widgets/app_error_state.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/dinix_scaffold.dart';
import 'package:app_dinix/widgets/empty.dart';
import 'package:app_dinix/widgets/lista_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class RecebimentosMensaisPage extends StatefulWidget {
  const RecebimentosMensaisPage({super.key});

  @override
  State<RecebimentosMensaisPage> createState() =>
      _RecebimentosMensaisPageState();
}

class _RecebimentosMensaisPageState extends State<RecebimentosMensaisPage> {
  bool _loading = true;
  ErrorModel? _erro;
  List<RecebimentoMensalModel> _itens = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar({bool forceRefresh = false}) async {
    setState(() {
      _loading = _itens.isEmpty;
      _erro = null;
    });
    try {
      final pagina = await listarRecebimentosMensais(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _itens = pagina.itens;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _erro = errorModelFromException(e);
      });
    }
  }

  Future<void> _abrirCadastro({RecebimentoMensalModel? item}) async {
    final salvo = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (_) => CadastroRecebimentoMensalPage(recebimento: item),
      ),
    );
    if (salvo == true && mounted) {
      await _carregar(forceRefresh: true);
    }
  }

  Widget _item(RecebimentoMensalModel item) {
    final detalhes = [
      'Dia ${item.diaRecebimento ?? '-'}',
      if ((item.dataFim ?? '').isNotEmpty) 'com data fim',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: ListTile(
          onTap: () => _abrirCadastro(item: item),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DinixColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Phosphor.trendUp,
              color: DinixColors.primary,
              size: 22,
            ),
          ),
          title: appText(
            item.nome ?? '',
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
            formataMoeda(item.valor),
            bold: true,
            color: const Color(0xFF4CAF50),
            fontSize: AppFontSizes.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return dinixMenuScaffold(
      title: 'Recebimentos mensais',
      onAdd: () => _abrirCadastro(),
      addTooltip: 'Novo recebimento',
      body: _loading
          ? appLoadingDinix()
          : _erro != null
              ? appErrorState(
                  errorModel: _erro!,
                  subtitle: 'Não foi possível carregar os recebimentos.',
                  onRetry: () => _carregar(forceRefresh: true),
                )
              : _itens.isEmpty
                  ? listaRefreshVazia(
                      context: context,
                      onRefresh: () => _carregar(forceRefresh: true),
                      child: emptyMessage(
                        title: 'Nenhum recebimento mensal',
                        subtitle:
                            'Cadastre salário e outras entradas que se repetem todo mês.',
                        icon: Phosphor.trendUp,
                      ),
                    )
                  : listaRefreshBuilder(
                      onRefresh: () => _carregar(forceRefresh: true),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      itemCount: _itens.length,
                      itemBuilder: (_, i) => _item(_itens[i]),
                    ),
    );
  }
}

import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/models/gasto_mensal_model.dart';
import 'package:app_dinix/pages/gastos_mensais/cadastro_gasto_mensal_page.dart';
import 'package:app_dinix/pages/gastos_mensais/gastos_mensais_service.dart';
import 'package:app_dinix/widgets/app_error_state.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/dinix_scaffold.dart';
import 'package:app_dinix/widgets/empty.dart';
import 'package:app_dinix/widgets/lista_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class GastosMensaisPage extends StatefulWidget {
  const GastosMensaisPage({super.key});

  @override
  State<GastosMensaisPage> createState() => _GastosMensaisPageState();
}

class _GastosMensaisPageState extends State<GastosMensaisPage> {
  bool _loading = true;
  ErrorModel? _erro;
  List<GastoMensalModel> _itens = [];

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
      final pagina = await listarGastosMensais(forceRefresh: forceRefresh);
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

  Future<void> _abrirCadastro({GastoMensalModel? gasto}) async {
    final salvo = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (_) => CadastroGastoMensalPage(gasto: gasto),
      ),
    );
    if (salvo == true && mounted) {
      await _carregar(forceRefresh: true);
    }
  }

  String _formataMesAnoIso(String iso) {
    if (iso.length < 7) return iso;
    final parsed = DateTime.tryParse(iso.substring(0, 10));
    if (parsed == null) return iso;
    const meses = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return '${meses[parsed.month - 1]}/${parsed.year}';
  }

  Widget _item(GastoMensalModel gasto) {
    final detalhes = [
      'Dia ${gasto.diaVencimento ?? '-'}',
      FormaPagamento.rotulo(gasto.formaPagamento),
      if ((gasto.dataFim ?? '').isNotEmpty)
        'até ${_formataMesAnoIso(gasto.dataFim!)}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: ListTile(
          onTap: () => _abrirCadastro(gasto: gasto),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DinixColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Phosphor.calendarBlank,
              color: DinixColors.primary,
              size: 22,
            ),
          ),
          title: appText(
            gasto.nome ?? '',
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: AppFontSizes.small,
          ),
          subtitle: appText(
            detalhes,
            color: AppColors.grey400,
            fontSize: AppFontSizes.verySmall,
          ),
          trailing: appText(
            formataMoeda(gasto.valor),
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: AppFontSizes.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return dinixMenuScaffold(
      title: 'Gastos mensais',
      onAdd: () => _abrirCadastro(),
      addTooltip: 'Novo gasto mensal',
      body: _loading
          ? appLoadingDinix()
          : _erro != null
              ? appErrorState(
                  errorModel: _erro!,
                  subtitle: 'Não foi possível carregar os gastos mensais.',
                  onRetry: () => _carregar(forceRefresh: true),
                )
              : _itens.isEmpty
                  ? listaRefreshVazia(
                      context: context,
                      onRefresh: () => _carregar(forceRefresh: true),
                      child: emptyMessage(
                        title: 'Nenhum gasto mensal',
                        subtitle:
                            'Cadastre contas fixas como aluguel, internet ou academia.',
                        icon: Phosphor.calendarBlank,
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

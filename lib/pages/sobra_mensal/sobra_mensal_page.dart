import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/pages/sobra_mensal/sobra_mensal_service.dart';
import 'package:app_dinix/widgets/app_error_state.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/dinix_scaffold.dart';
import 'package:app_dinix/widgets/fade_slide_in.dart';
import 'package:app_dinix/widgets/lista_refresh.dart';
import 'package:flutter/material.dart';
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

const _corReceita = Color(0xFF4CAF50);
const _corDespesa = Color(0xFFEF5350);

class SobraMensalPage extends StatefulWidget {
  const SobraMensalPage({super.key});

  @override
  State<SobraMensalPage> createState() => _SobraMensalPageState();
}

class _SobraMensalPageState extends State<SobraMensalPage> {
  bool _loading = true;
  ErrorModel? _erro;
  SobraMensalResumo? _resumo;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar({bool forceRefresh = false}) async {
    setState(() {
      _loading = _resumo == null;
      _erro = null;
    });
    try {
      final resumo = await carregarProjecaoSobra(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _resumo = resumo;
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

  Widget _cardResumo(SobraMensalResumo resumo) {
    final positiva = resumo.mediaSobra >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: positiva
              ? DinixColors.primary.withValues(alpha: 0.45)
              : _corDespesa.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(
            'Média dos próximos ${resumo.meses.length} meses',
            color: DinixColors.textMuted,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: 8),
          appText(
            formataMoeda(resumo.mediaSobra),
            bold: true,
            color: positiva ? DinixColors.primary : _corDespesa,
            fontSize: 28,
          ),
          appSizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _miniMetrica(
                  'Receitas',
                  formataMoeda(resumo.mediaReceitas),
                  _corReceita,
                ),
              ),
              appSizedBox(width: 10),
              Expanded(
                child: _miniMetrica(
                  'Saídas fixas',
                  formataMoeda(resumo.mediaSaidas),
                  _corDespesa,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniMetrica(String titulo, String valor, Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DinixColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(
            titulo,
            color: DinixColors.textMuted,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: 4),
          appText(
            valor,
            bold: true,
            color: cor,
            fontSize: AppFontSizes.small,
          ),
        ],
      ),
    );
  }

  Widget _cardMes(MesSobraProjecao mes) {
    final positiva = mes.sobra >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(
            '${_meses[mes.mes]} ${mes.ano}',
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: AppFontSizes.normal,
          ),
          appSizedBox(height: 12),
          _linhaDetalhe(
            'Receitas recorrentes',
            mes.receitas,
            _corReceita,
            prefixo: '+ ',
          ),
          _linhaDetalhe(
            'Gastos mensais',
            mes.gastosMensais,
            _corDespesa,
            prefixo: '- ',
          ),
          _linhaDetalhe(
            'Assinaturas',
            mes.assinaturas,
            _corDespesa,
            prefixo: '- ',
          ),
          _linhaDetalhe(
            'Faturas de cartão',
            mes.faturasCartoes,
            _corDespesa,
            prefixo: '- ',
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Divider(height: 1, color: AppColors.grey800),
          ),
          appSizedBox(height: 8),
          _linhaDetalhe(
            'Quanto sobra',
            mes.sobra,
            positiva ? DinixColors.primary : _corDespesa,
          ),
        ],
      ),
    );
  }

  Widget _linhaDetalhe(
    String titulo,
    double valor,
    Color cor, {
    String prefixo = '',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: appText(
              titulo,
              color: DinixColors.textMuted,
              fontSize: AppFontSizes.verySmall,
            ),
          ),
          appText(
            '$prefixo${formataMoeda(valor)}',
            color: cor,
            fontSize: AppFontSizes.small,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _conteudo(SobraMensalResumo resumo) {
    return dinixRefresh(
      onRefresh: () => _carregar(forceRefresh: true),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          appText(
            'Recebimentos mensais − gastos em conta − assinaturas em conta − faturas de cartão.',
            color: DinixColors.textMuted,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: 14),
          FadeSlideIn(index: 0, child: _cardResumo(resumo)),
          appSizedBox(height: 20),
          appText(
            'Mês a mês',
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: AppFontSizes.small,
          ),
          appSizedBox(height: 10),
          ...resumo.meses.asMap().entries.map(
            (entry) => FadeSlideIn(
              index: entry.key + 1,
              child: _cardMes(entry.value),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return dinixMenuScaffold(
      title: 'Simulação próximos meses',
      body: _loading
          ? appLoadingDinix()
          : _erro != null
              ? appErrorState(
                  errorModel: _erro!,
                  subtitle:
                      _erro!.mensagem ?? 'Não foi possível calcular a sobra.',
                  onRetry: () => _carregar(forceRefresh: true),
                )
              : _conteudo(_resumo!),
    );
  }
}

import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/painel_model.dart';
import 'package:app_dinix/pages/dashboards/dashboards_service.dart';
import 'package:app_dinix/pages/dashboards/widgets/dashboard_charts.dart';
import 'package:app_dinix/pages/dashboards/widgets/dashboard_widgets.dart';
import 'package:app_dinix/widgets/app_error_state.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/dinix_scaffold.dart';
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

class DashboardsPage extends StatefulWidget {
  const DashboardsPage({super.key});

  @override
  State<DashboardsPage> createState() => _DashboardsPageState();
}

class _DashboardsPageState extends State<DashboardsPage> {
  bool _loading = true;
  ErrorModel? _erro;
  DashboardsData? _data;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar({bool forceRefresh = false}) async {
    setState(() {
      _loading = _data == null;
      _erro = null;
    });
    try {
      final data = await carregarDashboards(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _data = data;
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

  String _nomeMes(int mes, int ano) {
    final nome = (mes >= 1 && mes <= 12) ? _meses[mes] : '';
    return nome.isEmpty ? '$mes/$ano' : '$nome $ano';
  }

  String _variacao(double percentual) {
    final sinal = percentual > 0 ? '+' : '';
    final texto = percentual == percentual.roundToDouble()
        ? percentual.toStringAsFixed(0)
        : percentual.toStringAsFixed(1);
    return '$sinal$texto% vs mês anterior';
  }

  Color _corVariacao(double percentual, {required bool receita}) {
    if (percentual == 0) return DinixColors.textMuted;
    if (receita) return percentual > 0 ? _corReceita : _corDespesa;
    return percentual > 0 ? _corDespesa : _corReceita;
  }

  ({double total, double usado, double disponivel}) _totaisCartoes(
    List<CartaoCreditoModel> cartoes,
  ) {
    var total = 0.0;
    var usado = 0.0;
    var disponivel = 0.0;
    for (final cartao in cartoes) {
      final limite = cartao.limite ?? 0;
      final usadoCartao = cartao.limiteUsado ?? 0;
      final disp = cartao.limiteDisponivel ??
          (limite - usadoCartao).clamp(0.0, limite);
      total += limite;
      usado += usadoCartao;
      disponivel += disp;
    }
    return (total: total, usado: usado, disponivel: disponivel);
  }

  Widget _secaoResumo(PainelModel painel) {
    final disponivelPositivo = painel.disponivel >= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecaoTitulo(
          'Resumo do mês',
          icon: Phosphor.calendarBlank,
        ),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              appText(
                _nomeMes(painel.mes, painel.ano),
                color: DinixColors.textMuted,
                fontSize: AppFontSizes.verySmall,
              ),
              appSizedBox(height: 12),
              MetricRow(
                label: 'Receitas',
                value: formataMoeda(painel.receitas.total),
                valueColor: _corReceita,
                hint: _variacao(painel.receitas.percentualVariacao),
              ),
              MetricRow(
                label: 'Despesas',
                value: formataMoeda(painel.despesas.total),
                valueColor: _corDespesa,
                hint: _variacao(painel.despesas.percentualVariacao),
              ),
              const Divider(height: 20, color: Color(0xFF2A2A2E)),
              MetricRow(
                label: 'Disponível',
                value: formataMoeda(painel.disponivel),
                valueColor:
                    disponivelPositivo ? DinixColors.primary : _corDespesa,
              ),
              appSizedBox(height: 14),
              appText(
                'Receitas × despesas',
                bold: true,
                color: DinixColors.textPrimary,
                fontSize: AppFontSizes.verySmall,
              ),
              appSizedBox(height: 10),
              GraficoReceitasDespesas(
                receitas: painel.receitas,
                despesas: painel.despesas,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _secaoCartoes(List<CartaoCreditoModel> cartoes) {
    final totais = _totaisCartoes(cartoes);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SecaoTitulo('Cartões', icon: Phosphor.creditCard),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MetricRow(
                label: 'Limite total',
                value: formataMoeda(totais.total),
              ),
              MetricRow(
                label: 'Usado',
                value: formataMoeda(totais.usado),
                valueColor: _corDespesa,
              ),
              MetricRow(
                label: 'Disponível',
                value: formataMoeda(totais.disponivel),
                valueColor: _corReceita,
              ),
              if (cartoes.isNotEmpty) ...[
                appSizedBox(height: 8),
                BarraLimite(usado: totais.usado, limite: totais.total),
                appSizedBox(height: 14),
                appText(
                  'Uso do limite por cartão',
                  bold: true,
                  color: DinixColors.textPrimary,
                  fontSize: AppFontSizes.verySmall,
                ),
                appSizedBox(height: 10),
                GraficoUsoCartoes(cartoes: cartoes),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: appText(
                    'Nenhum cartão cadastrado.',
                    color: DinixColors.textMuted,
                    fontSize: AppFontSizes.verySmall,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _secaoMetricaPeriodo({
    required String titulo,
    required IconData icon,
    required PeriodoMetricaModel metrica,
    required Color valorColor,
    required bool receita,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecaoTitulo(titulo, icon: icon),
        DashboardCard(
          child: Column(
            children: [
              MetricRow(
                label: 'Total',
                value: formataMoeda(metrica.total),
                valueColor: valorColor,
              ),
              MetricRow(
                label: 'Lançamentos',
                value: '${metrica.quantidade}',
              ),
              MetricRow(
                label: 'Variação',
                value: _variacao(metrica.percentualVariacao)
                    .replaceAll(' vs mês anterior', ''),
                valueColor: _corVariacao(
                  metrica.percentualVariacao,
                  receita: receita,
                ),
                hint: 'Comparado ao mês anterior',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _secaoGastos(PainelModel painel) {
    final categorias = painel.despesasPorCategoria.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _secaoMetricaPeriodo(
          titulo: 'Gastos',
          icon: Phosphor.arrowDown,
          metrica: painel.despesas,
          valorColor: _corDespesa,
          receita: false,
        ),
        if (categorias.isNotEmpty) ...[
          appSizedBox(height: 10),
          DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                appText(
                  'Gastos por categoria',
                  bold: true,
                  color: DinixColors.textPrimary,
                  fontSize: AppFontSizes.verySmall,
                ),
                appSizedBox(height: 10),
                GraficoCategoriasDespesa(
                  categorias: painel.despesasPorCategoria,
                ),
                appSizedBox(height: 14),
                appText(
                  'Detalhe',
                  bold: true,
                  color: DinixColors.textPrimary,
                  fontSize: AppFontSizes.verySmall,
                ),
                appSizedBox(height: 6),
                ...categorias.map((item) {
                  final pct = item.percentual == item.percentual.roundToDouble()
                      ? item.percentual.toStringAsFixed(0)
                      : item.percentual.toStringAsFixed(1);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: appText(
                            item.categoria.isEmpty
                                ? 'Sem categoria'
                                : item.categoria,
                            color: DinixColors.textPrimary,
                            fontSize: AppFontSizes.verySmall,
                          ),
                        ),
                        appText(
                          '$pct%',
                          color: DinixColors.textMuted,
                          fontSize: 11,
                        ),
                        appSizedBox(width: 10),
                        appText(
                          formataMoeda(item.valor),
                          bold: true,
                          color: _corDespesa,
                          fontSize: AppFontSizes.verySmall,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _secaoAssinaturas(DashboardsData data) {
    final resumo = data.assinaturas;
    final proximos = resumo.proximosPagamentos.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SecaoTitulo('Assinaturas', icon: Phosphor.stack),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MetricRow(
                label: 'Total mensal',
                value: formataMoeda(resumo.totalMensal),
                valueColor: _corDespesa,
              ),
              MetricRow(
                label: 'Total anual',
                value: formataMoeda(resumo.totalAnual),
              ),
              if (proximos.isNotEmpty) ...[
                appSizedBox(height: 12),
                appText(
                  'Próximos pagamentos',
                  bold: true,
                  color: DinixColors.textPrimary,
                  fontSize: AppFontSizes.verySmall,
                ),
                appSizedBox(height: 10),
                GraficoAssinaturasProximas(pagamentos: proximos),
                appSizedBox(height: 6),
                ...proximos.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              appText(
                                item.nome,
                                color: DinixColors.textPrimary,
                                fontSize: AppFontSizes.verySmall,
                              ),
                              if ((item.data ?? '').isNotEmpty)
                                appText(
                                  isoParaBr(item.data),
                                  color: DinixColors.textMuted,
                                  fontSize: 11,
                                ),
                            ],
                          ),
                        ),
                        appText(
                          formataMoeda(item.valor),
                          bold: true,
                          color: _corDespesa,
                          fontSize: AppFontSizes.verySmall,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _secaoPatrimonio(DashboardsData data) {
    final p = data.patrimonio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SecaoTitulo('Patrimônio', icon: Phosphor.wallet),
        DashboardCard(
          child: Column(
            children: [
              MetricRow(
                label: 'Saldo em contas',
                value: formataMoeda(p.saldoContas),
              ),
              MetricRow(
                label: 'Investimentos',
                value: formataMoeda(p.valorInvestimentos),
                valueColor: _corReceita,
              ),
              MetricRow(
                label: 'Dívidas',
                value: formataMoeda(p.dividas),
                valueColor: _corDespesa,
              ),
              const Divider(height: 20, color: Color(0xFF2A2A2E)),
              MetricRow(
                label: 'Patrimônio líquido',
                value: formataMoeda(p.patrimonio),
                valueColor: p.patrimonio >= 0
                    ? DinixColors.primary
                    : _corDespesa,
              ),
              appSizedBox(height: 14),
              appText(
                'Composição',
                bold: true,
                color: DinixColors.textPrimary,
                fontSize: AppFontSizes.verySmall,
              ),
              appSizedBox(height: 10),
              GraficoComposicaoPatrimonio(patrimonio: p),
              appSizedBox(height: 14),
              appText(
                'Evolução',
                bold: true,
                color: DinixColors.textPrimary,
                fontSize: AppFontSizes.verySmall,
              ),
              appSizedBox(height: 10),
              GraficoEvolucaoPatrimonio(
                historico: data.patrimonioHistorico,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _secaoPrevisao(DashboardsData data) {
    final p = data.previsao;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecaoTitulo(
          'Previsão — ${_nomeMes(p.mes, p.ano)}',
          icon: Phosphor.chartLineUp,
        ),
        DashboardCard(
          child: Column(
            children: [
              MetricRow(
                label: 'Receitas previstas',
                value: formataMoeda(p.receitasPrevistas),
                valueColor: _corReceita,
              ),
              MetricRow(
                label: 'Despesas comprometidas',
                value: formataMoeda(p.despesasComprometidas),
                valueColor: _corDespesa,
              ),
              if (p.investimentosPrevistos != 0)
                MetricRow(
                  label: 'Investimentos previstos',
                  value: formataMoeda(p.investimentosPrevistos),
                ),
              const Divider(height: 20, color: Color(0xFF2A2A2E)),
              MetricRow(
                label: 'Disponível previsto',
                value: formataMoeda(p.disponivelPrevisto),
                valueColor: p.disponivelPrevisto >= 0
                    ? DinixColors.primary
                    : _corDespesa,
              ),
              appSizedBox(height: 14),
              appText(
                'Visão do próximo mês',
                bold: true,
                color: DinixColors.textPrimary,
                fontSize: AppFontSizes.verySmall,
              ),
              appSizedBox(height: 10),
              GraficoPrevisao(previsao: p),
            ],
          ),
        ),
      ],
    );
  }

  Widget _conteudo(DashboardsData data) {
    return dinixRefresh(
      onRefresh: () => _carregar(forceRefresh: true),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _secaoResumo(data.painel),
          appSizedBox(height: 22),
          _secaoCartoes(data.painel.cartoes),
          appSizedBox(height: 22),
          _secaoMetricaPeriodo(
            titulo: 'Ganhos',
            icon: Phosphor.trendUp,
            metrica: data.painel.receitas,
            valorColor: _corReceita,
            receita: true,
          ),
          appSizedBox(height: 22),
          _secaoGastos(data.painel),
          appSizedBox(height: 22),
          _secaoAssinaturas(data),
          appSizedBox(height: 22),
          _secaoPatrimonio(data),
          appSizedBox(height: 22),
          _secaoPrevisao(data),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return dinixMenuScaffold(
      title: 'Dashboards',
      body: _loading
          ? appLoadingDinix()
          : _erro != null
              ? appErrorState(
                  errorModel: _erro!,
                  subtitle:
                      _erro!.mensagem ?? 'Não foi possível carregar os dashboards.',
                  onRetry: () => _carregar(forceRefresh: true),
                )
              : _conteudo(_data!),
    );
  }
}

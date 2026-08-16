import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/models/assinatura_resumo_model.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/painel_model.dart';
import 'package:app_dinix/models/patrimonio_historico_model.dart';
import 'package:app_dinix/models/patrimonio_model.dart';
import 'package:app_dinix/models/previsao_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

const _corReceita = Color(0xFF4CAF50);
const _corDespesa = Color(0xFFEF5350);
const _corInvest = Color(0xFF42A5F5);
const _corDivida = Color(0xFFFF7043);
const _mesesCurtos = [
  '',
  'Jan',
  'Fev',
  'Mar',
  'Abr',
  'Mai',
  'Jun',
  'Jul',
  'Ago',
  'Set',
  'Out',
  'Nov',
  'Dez',
];

List<Color> get _coresCategoria => [
      DinixColors.primary,
      const Color(0xFF42A5F5),
      const Color(0xFFAB47BC),
      const Color(0xFF26A69A),
      const Color(0xFFEF5350),
      const Color(0xFFFFCA28),
      const Color(0xFF8D6E63),
      const Color(0xFF78909C),
    ];

class ChartEmptyHint extends StatelessWidget {
  final String message;

  const ChartEmptyHint(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: appText(
          message,
          color: DinixColors.textMuted,
          fontSize: AppFontSizes.verySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class ChartLegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const ChartLegendDot({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        appSizedBox(width: 6),
        Flexible(
          child: appText(
            label,
            color: DinixColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

String _moedaCurta(double value) {
  final abs = value.abs();
  if (abs >= 1000000) {
    return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (abs >= 1000) {
    return 'R\$ ${(value / 1000).toStringAsFixed(abs >= 10000 ? 0 : 1)}k';
  }
  return formataMoeda(value);
}

/// Barras: receitas x despesas (atual vs anterior).
class GraficoReceitasDespesas extends StatelessWidget {
  final PeriodoMetricaModel receitas;
  final PeriodoMetricaModel despesas;

  const GraficoReceitasDespesas({
    super.key,
    required this.receitas,
    required this.despesas,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = [
      receitas.total,
      receitas.totalAnterior,
      despesas.total,
      despesas.totalAnterior,
    ].fold<double>(0, (a, b) => a > b ? a : b);
    if (maxY <= 0) {
      return const ChartEmptyHint('Sem dados para comparar o mês.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.15,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.grey800,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, _) => appText(
                      _moedaCurta(value),
                      color: DinixColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final labels = ['Anterior', 'Atual'];
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: appText(
                          labels[i],
                          color: DinixColors.textMuted,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barsSpace: 6,
                  barRods: [
                    BarChartRodData(
                      toY: receitas.totalAnterior,
                      color: _corReceita.withValues(alpha: 0.45),
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: despesas.totalAnterior,
                      color: _corDespesa.withValues(alpha: 0.45),
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barsSpace: 6,
                  barRods: [
                    BarChartRodData(
                      toY: receitas.total,
                      color: _corReceita,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: despesas.total,
                      color: _corDespesa,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        appSizedBox(height: 10),
        const Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            ChartLegendDot(color: _corReceita, label: 'Receitas'),
            ChartLegendDot(color: _corDespesa, label: 'Despesas'),
          ],
        ),
      ],
    );
  }
}

/// Donut: gastos por categoria.
class GraficoCategoriasDespesa extends StatelessWidget {
  final List<DespesaPorCategoriaModel> categorias;

  const GraficoCategoriasDespesa({super.key, required this.categorias});

  @override
  Widget build(BuildContext context) {
    final itens = categorias.where((e) => e.valor > 0).take(6).toList();
    if (itens.isEmpty) {
      return const ChartEmptyHint('Sem gastos por categoria neste mês.');
    }
    final total = itens.fold<double>(0, (a, b) => a + b.valor);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 42,
              sections: [
                for (var i = 0; i < itens.length; i++)
                  PieChartSectionData(
                    value: itens[i].valor,
                    color: _coresCategoria[i % _coresCategoria.length],
                    radius: 34,
                    title: total <= 0
                        ? ''
                        : '${((itens[i].valor / total) * 100).round()}%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
        appSizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (var i = 0; i < itens.length; i++)
              ChartLegendDot(
                color: _coresCategoria[i % _coresCategoria.length],
                label: itens[i].categoria.isEmpty
                    ? 'Outros'
                    : itens[i].categoria,
              ),
          ],
        ),
      ],
    );
  }
}

/// Barras horizontais: uso de limite por cartão.
class GraficoUsoCartoes extends StatelessWidget {
  final List<CartaoCreditoModel> cartoes;

  const GraficoUsoCartoes({super.key, required this.cartoes});

  @override
  Widget build(BuildContext context) {
    final itens = cartoes
        .where((c) => (c.limite ?? 0) > 0 || (c.limiteUsado ?? 0) > 0)
        .toList();
    if (itens.isEmpty) {
      return const ChartEmptyHint('Cadastre cartões para ver o uso do limite.');
    }

    final maxLimite =
        itens.map((c) => c.limite ?? 0).fold<double>(0, (a, b) => a > b ? a : b);
    if (maxLimite <= 0) {
      return const ChartEmptyHint('Sem limite cadastrado nos cartões.');
    }

    return Column(
      children: [
        for (final cartao in itens.take(6)) ...[
          Builder(builder: (_) {
            final limite = cartao.limite ?? 0;
            final usado = cartao.limiteUsado ?? 0;
            final pct = limite <= 0 ? 0.0 : (usado / limite).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: appText(
                          cartao.nome ?? 'Cartão',
                          color: DinixColors.textPrimary,
                          fontSize: 11,
                        ),
                      ),
                      appText(
                        '${(pct * 100).round()}%',
                        color: DinixColors.textMuted,
                        fontSize: 11,
                      ),
                    ],
                  ),
                  appSizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 10,
                      child: Stack(
                        children: [
                          Container(color: AppColors.grey800),
                          FractionallySizedBox(
                            widthFactor: (limite / maxLimite).clamp(0.0, 1.0),
                            child: Stack(
                              children: [
                                Container(
                                  color: DinixColors.primary
                                      .withValues(alpha: 0.22),
                                ),
                                FractionallySizedBox(
                                  widthFactor: pct,
                                  child: Container(
                                    color: pct > 0.85
                                        ? _corDespesa
                                        : DinixColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

/// Donut: composição do patrimônio.
class GraficoComposicaoPatrimonio extends StatelessWidget {
  final PatrimonioModel patrimonio;

  const GraficoComposicaoPatrimonio({super.key, required this.patrimonio});

  @override
  Widget build(BuildContext context) {
    final slices = <({String label, double value, Color color})>[
      (
        label: 'Contas',
        value: patrimonio.saldoContas.clamp(0, double.infinity),
        color: DinixColors.primary,
      ),
      (
        label: 'Investimentos',
        value: patrimonio.valorInvestimentos.clamp(0, double.infinity),
        color: _corInvest,
      ),
      (
        label: 'Dívidas',
        value: patrimonio.dividas.clamp(0, double.infinity),
        color: _corDivida,
      ),
    ].where((e) => e.value > 0).toList();

    if (slices.isEmpty) {
      return const ChartEmptyHint('Sem composição de patrimônio ainda.');
    }

    final total = slices.fold<double>(0, (a, b) => a + b.value);

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                for (final s in slices)
                  PieChartSectionData(
                    value: s.value,
                    color: s.color,
                    radius: 32,
                    title: total <= 0
                        ? ''
                        : '${((s.value / total) * 100).round()}%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
        appSizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (final s in slices)
              ChartLegendDot(color: s.color, label: s.label),
          ],
        ),
      ],
    );
  }
}

/// Linha: evolução do patrimônio líquido.
class GraficoEvolucaoPatrimonio extends StatelessWidget {
  final List<PatrimonioHistoricoItem> historico;

  const GraficoEvolucaoPatrimonio({super.key, required this.historico});

  @override
  Widget build(BuildContext context) {
    if (historico.length < 2) {
      return const ChartEmptyHint(
        'Histórico insuficiente. Volte nos próximos meses para ver a evolução.',
      );
    }

    final spots = <FlSpot>[
      for (var i = 0; i < historico.length; i++)
        FlSpot(i.toDouble(), historico[i].patrimonio),
    ];
    final valores = historico.map((e) => e.patrimonio).toList();
    final minV = valores.reduce((a, b) => a < b ? a : b);
    final maxV = valores.reduce((a, b) => a > b ? a : b);
    final pad = ((maxV - minV).abs() * 0.12).clamp(1.0, double.infinity);

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: minV - pad,
          maxY: maxV + pad,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.grey800,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, _) => appText(
                  _moedaCurta(value),
                  color: DinixColors.textMuted,
                  fontSize: 9,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= historico.length) {
                    return const SizedBox.shrink();
                  }
                  // Mostra só alguns rótulos para não poluir.
                  if (historico.length > 6 &&
                      i != 0 &&
                      i != historico.length - 1 &&
                      i % 2 != 0) {
                    return const SizedBox.shrink();
                  }
                  final item = historico[i];
                  final mes = (item.mes >= 1 && item.mes <= 12)
                      ? _mesesCurtos[item.mes]
                      : '${item.mes}';
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: appText(
                      mes,
                      color: DinixColors.textMuted,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: DinixColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 3.5,
                  color: DinixColors.primary,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: DinixColors.primary.withValues(alpha: 0.15),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touched) => touched
                  .map(
                    (t) => LineTooltipItem(
                      _moedaCurta(t.y),
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barras: previsão do próximo mês.
class GraficoPrevisao extends StatelessWidget {
  final PrevisaoModel previsao;

  const GraficoPrevisao({super.key, required this.previsao});

  @override
  Widget build(BuildContext context) {
    final valores = [
      previsao.receitasPrevistas,
      previsao.despesasComprometidas,
      previsao.disponivelPrevisto.abs(),
    ];
    final maxY = valores.fold<double>(0, (a, b) => a > b ? a : b);
    if (maxY <= 0) {
      return const ChartEmptyHint('Sem previsão disponível.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 170,
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.15,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.grey800,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, _) => appText(
                      _moedaCurta(value),
                      color: DinixColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      const labels = ['Receitas', 'Despesas', 'Disponível'];
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: appText(
                          labels[i],
                          color: DinixColors.textMuted,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                _rod(0, previsao.receitasPrevistas, _corReceita),
                _rod(1, previsao.despesasComprometidas, _corDespesa),
                _rod(
                  2,
                  previsao.disponivelPrevisto.abs(),
                  previsao.disponivelPrevisto >= 0
                      ? DinixColors.primary
                      : _corDespesa,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _rod(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}

/// Barras horizontais: próximas assinaturas.
class GraficoAssinaturasProximas extends StatelessWidget {
  final List<AssinaturaProximoPagamentoModel> pagamentos;

  const GraficoAssinaturasProximas({super.key, required this.pagamentos});

  @override
  Widget build(BuildContext context) {
    final itens = pagamentos.where((e) => e.valor > 0).take(5).toList();
    if (itens.isEmpty) {
      return const ChartEmptyHint('Nenhum pagamento de assinatura próximo.');
    }
    final maxV =
        itens.map((e) => e.valor).fold<double>(0, (a, b) => a > b ? a : b);

    return Column(
      children: [
        for (final item in itens)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: appText(
                        item.nome,
                        color: DinixColors.textPrimary,
                        fontSize: 11,
                      ),
                    ),
                    appText(
                      formataMoeda(item.valor),
                      color: _corDespesa,
                      fontSize: 11,
                      bold: true,
                    ),
                  ],
                ),
                appSizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: maxV <= 0 ? 0 : (item.valor / maxV).clamp(0.0, 1.0),
                    minHeight: 8,
                    color: _corDespesa,
                    backgroundColor: AppColors.grey800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

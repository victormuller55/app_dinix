import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/painel_model.dart';
import 'package:app_dinix/pages/carteiras/cartoes/detalhe_cartao/detalhe_cartao_page.dart';
import 'package:app_dinix/pages/compras/compras_page.dart';
import 'package:app_dinix/pages/painel/painel_bloc.dart';
import 'package:app_dinix/pages/painel/painel_event.dart';
import 'package:app_dinix/pages/painel/painel_state.dart';
import 'package:app_dinix/pages/receitas/receitas_page.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_error_state.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:app_dinix/widgets/dinix_scaffold.dart';
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

class PainelPage extends StatefulWidget {
  const PainelPage({super.key});

  @override
  State<PainelPage> createState() => _PainelPageState();
}

class _PainelPageState extends State<PainelPage> {
  final PainelBloc bloc = PainelBloc();

  @override
  void initState() {
    super.initState();
    bloc.add(PainelLoadEvent());
  }

  String _rotuloMes(int mes, int ano) {
    if (mes >= 1 && mes <= 12) return '${_meses[mes]} $ano';
    return '$mes/$ano';
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return Material(
      color: DinixColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  Widget _saldoContas(double saldo) {
    return _card(
      child: Column(
        children: [
          appText(
            'Saldo em contas',
            color: AppColors.grey400,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: 8),
          appText(
            formataMoeda(saldo),
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: 32,
          ),
        ],
      ),
    );
  }

  Widget _valoresInvestidos(double total) {
    return _card(
      child: Column(
        children: [
          appText(
            'Valores investidos',
            color: AppColors.grey400,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: 8),
          appText(
            formataMoeda(total),
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: 32,
          ),
        ],
      ),
    );
  }

  Widget _metricaMini({
    required String titulo,
    required double valor,
    required Color cor,
  }) {
    return Expanded(
      child: _card(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appText(
              titulo,
              color: AppColors.grey400,
              fontSize: AppFontSizes.verySmall,
            ),
            appSizedBox(height: 6),
            appText(
              formataMoeda(valor),
              bold: true,
              color: cor,
              fontSize: AppFontSizes.small,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoCredito(CartaoCreditoModel cartao) {
    final limite = cartao.limite ?? 0;
    final usado = cartao.limiteUsado ?? 0;
    final disponivel =
        cartao.limiteDisponivel ?? (limite - usado).clamp(0.0, limite);
    final percentual = limite <= 0 ? 0.0 : (usado / limite).clamp(0.0, 1.0);

    return _card(
      padding: const EdgeInsets.all(12),
      onTap: () async {
        await Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => DetalheCartaoPage(cartao: cartao),
          ),
        );
        if (mounted) {
          bloc.add(PainelLoadEvent(forceRefresh: true));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              bancoIcon(
                banco: cartao.banco,
                fallback: cartao.nome,
                size: 28,
              ),
              appSizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appText(
                      cartao.nome ?? '',
                      bold: true,
                      color: DinixColors.textPrimary,
                      fontSize: AppFontSizes.verySmall,
                    ),
                    if ((cartao.banco ?? '').isNotEmpty)
                      appText(
                        cartao.banco ?? '',
                        color: AppColors.grey400,
                        fontSize: 11,
                      ),
                  ],
                ),
              ),
            ],
          ),
          appSizedBox(height: 10),
          appText(
            'Disponível',
            color: AppColors.grey400,
            fontSize: 11,
          ),
          appSizedBox(height: 2),
          appText(
            formataMoeda(disponivel),
            bold: true,
            color: const Color(0xFF4CAF50),
            fontSize: AppFontSizes.small,
          ),
          appSizedBox(height: 4),
          appText(
            'Usado ${formataMoeda(usado)}',
            color: const Color(0xFFEF5350),
            fontSize: 11,
          ),
          appSizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentual,
              minHeight: 5,
              color: DinixColors.primary,
              backgroundColor: AppColors.grey800,
            ),
          ),
          appSizedBox(height: 6),
          appText(
            'Limite ${formataMoeda(limite)}',
            color: AppColors.grey400,
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  ({double sobrando, double usado, double total}) _totaisLimite(
    List<CartaoCreditoModel> cartoes,
  ) {
    var sobrando = 0.0;
    var usado = 0.0;
    var total = 0.0;
    for (final cartao in cartoes) {
      final limite = cartao.limite ?? 0;
      final usadoCartao = cartao.limiteUsado ?? 0;
      final disponivel = cartao.limiteDisponivel ??
          (limite - usadoCartao).clamp(0.0, limite);
      sobrando += disponivel;
      usado += usadoCartao;
      total += limite;
    }
    return (sobrando: sobrando, usado: usado, total: total);
  }

  Widget _limiteSobrandoCard({
    required double sobrando,
    required double usado,
    required double total,
  }) {
    final percentual = total <= 0 ? 0.0 : (usado / total * 100).clamp(0.0, 100.0);
    final percentualTexto = percentual == percentual.roundToDouble()
        ? percentual.toStringAsFixed(0)
        : percentual.toStringAsFixed(1);

    return _card(
      child: Column(
        children: [
          appText(
            'Limite sobrando',
            color: AppColors.grey400,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: 8),
          appText(
            formataMoeda(sobrando),
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: 32,
          ),
          appSizedBox(height: 8),
          appText(
            '${formataMoeda(usado)} / ${formataMoeda(total)}',
            color: AppColors.grey400,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: 2),
          appText(
            '$percentualTexto% do limite total usado',
            color: AppColors.grey400,
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  Widget _cartoesCredito(List<CartaoCreditoModel> cartoes) {
    if (cartoes.isEmpty) return const SizedBox.shrink();

    final totais = _totaisLimite(cartoes);
    final linhas = <Widget>[];
    for (var i = 0; i < cartoes.length; i += 2) {
      final esquerda = cartoes[i];
      final direita = i + 1 < cartoes.length ? cartoes[i + 1] : null;
      linhas.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < cartoes.length ? 10 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _cartaoCredito(esquerda)),
              appSizedBox(width: AppSpacing.normal),
              Expanded(
                child: direita == null
                    ? const SizedBox.shrink()
                    : _cartaoCredito(direita),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _secaoTitulo('Cartões de crédito'),
        _limiteSobrandoCard(
          sobrando: totais.sobrando,
          usado: totais.usado,
          total: totais.total,
        ),
        appSizedBox(height: 10),
        ...linhas,
      ],
    );
  }

  Widget _resumoMes(PainelModel painel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        appText(
          'Resumo de ${_rotuloMes(painel.mes, painel.ano)}',
          bold: true,
          color: DinixColors.textPrimary,
          fontSize: AppFontSizes.small,
        ),
        appSizedBox(height: 10),
        Row(
          children: [
            _metricaMini(
              titulo: 'Receitas',
              valor: painel.receitas.total,
              cor: const Color(0xFF4CAF50),
            ),
            appSizedBox(width: AppSpacing.normal),
            _metricaMini(
              titulo: 'Despesas',
              valor: painel.despesas.total,
              cor: const Color(0xFFEF5350),
            ),
          ],
        ),
      ],
    );
  }

  Widget _secaoTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: appText(
        titulo,
        bold: true,
        color: DinixColors.textPrimary,
        fontSize: AppFontSizes.small,
      ),
    );
  }

  Widget _categorias(List<DespesaPorCategoriaModel> itens) {
    if (itens.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _secaoTitulo('Despesas por categoria'),
        ...itens.take(5).map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _card(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: appText(
                      item.categoria,
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
            ),
          );
        }),
      ],
    );
  }

  String _rotuloTipoPagamento(String tipo) {
    switch (tipo) {
      case 'parcela':
        return 'Parcela';
      case 'assinatura':
        return 'Assinatura';
      case 'despesa_recorrente':
        return 'Recorrente';
      default:
        return tipo;
    }
  }

  Widget _proximosPagamentos(List<ProximoPagamentoModel> itens) {
    if (itens.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _secaoTitulo('Próximos pagamentos'),
        ...itens.take(6).map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _card(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        appText(
                          item.descricao,
                          bold: true,
                          color: DinixColors.textPrimary,
                          fontSize: AppFontSizes.small,
                        ),
                        appText(
                          '${_rotuloTipoPagamento(item.tipo)} · ${isoParaBr(item.dataVencimento)}',
                          color: AppColors.grey400,
                          fontSize: AppFontSizes.verySmall,
                        ),
                      ],
                    ),
                  ),
                  appText(
                    formataMoeda(item.valor),
                    bold: true,
                    color: const Color(0xFFEF5350),
                    fontSize: AppFontSizes.small,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _atalhos() {
    return Row(
      children: [
        Expanded(
          child: appElevatedButtonDinix(
            title: 'Entradas',
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const ReceitasPage()),
            ),
            height: 46,
          ),
        ),
        appSizedBox(width: AppSpacing.normal),
        Expanded(
          child: appElevatedButtonDinix(
            title: 'Saídas',
            invertedStyle: true,
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const ComprasPage()),
            ),
            height: 46,
          ),
        ),
      ],
    );
  }

  Widget _conteudo(PainelResumoModel resumo) {
    final painel = resumo.painel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _saldoContas(resumo.saldoContas),
        appSizedBox(height: 12),
        _valoresInvestidos(resumo.totalInvestimentos),
        appSizedBox(height: 16),
        _cartoesCredito(painel.cartoes),
        if (painel.cartoes.isNotEmpty) appSizedBox(height: 16),
        _resumoMes(painel),
        appSizedBox(height: 16),
        _atalhos(),
        if (painel.receitas.total == 0 &&
            painel.despesas.total == 0 &&
            resumo.saldoContas == 0 &&
            resumo.totalInvestimentos == 0)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: appText(
              'Cadastre contas, ganhos e compras para ver seu resumo completo.',
              color: AppColors.grey400,
              fontSize: AppFontSizes.verySmall,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _error(ErrorModel errorModel) {
    return appErrorState(
      errorModel: errorModel,
      subtitle: errorModel.mensagem ?? 'Não foi possível carregar o painel.',
      onRetry: () => bloc.add(PainelLoadEvent(forceRefresh: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return dinixMenuScaffold(
      title: 'Início',
      body: BlocBuilder<PainelBloc, PainelState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is PainelLoadingState || state is PainelInitialState) {
            return appLoadingDinix();
          }
          if (state is PainelErrorState) return _error(state.errorModel);
          if (state is PainelSuccessState) {
            return dinixRefresh(
              onRefresh: () async =>
                  bloc.add(PainelLoadEvent(forceRefresh: true)),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: _conteudo(state.resumo),
            );
          }
          return appLoadingDinix();
        },
      ),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}

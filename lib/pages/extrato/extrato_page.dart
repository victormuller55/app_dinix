import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/models/transacao_model.dart';
import 'package:app_dinix/pages/extrato/extrato_service.dart';
import 'package:app_dinix/widgets/app_error_state.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/dinix_scaffold.dart';
import 'package:app_dinix/widgets/empty.dart';
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
const _corInvest = Color(0xFF42A5F5);
const _corTransfer = Color(0xFFAB47BC);

sealed class _LinhaExtrato {}

class _CabecalhoDia extends _LinhaExtrato {
  final String dataIso;
  _CabecalhoDia(this.dataIso);
}

class _ItemTransacao extends _LinhaExtrato {
  final TransacaoModel transacao;
  _ItemTransacao(this.transacao);
}

class ExtratoPage extends StatefulWidget {
  const ExtratoPage({super.key});

  @override
  State<ExtratoPage> createState() => _ExtratoPageState();
}

class _ExtratoPageState extends State<ExtratoPage> {
  final _scroll = ScrollController();

  ExtratoFiltro _filtro = ExtratoFiltro.mesAtual();
  ExtratoLookups _lookups = ExtratoLookups.empty();
  final List<TransacaoModel> _itens = [];
  int _numPag = 1;
  int _maxPag = 1;
  bool _loading = true;
  bool _loadingMore = false;
  ErrorModel? _erro;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _carregar();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || _loading || _erro != null) return;
    if (_numPag >= _maxPag) return;
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels < _scroll.position.maxScrollExtent - 140) {
      return;
    }
    _carregarMais();
  }

  Future<void> _carregar({bool forceRefresh = false, bool limpar = false}) async {
    setState(() {
      _loading = _itens.isEmpty || limpar;
      _erro = null;
      if (forceRefresh || limpar) {
        _numPag = 1;
        _maxPag = 1;
      }
      if (limpar) {
        _itens.clear();
      }
    });
    try {
      final lookupsFuture = carregarLookupsExtrato();
      final pagina = await listarExtrato(filtro: _filtro, pagina: 1);
      final lookups = await lookupsFuture;
      if (!mounted) return;
      setState(() {
        _lookups = lookups;
        _itens
          ..clear()
          ..addAll(pagina.itens);
        _numPag = pagina.numPag;
        _maxPag = pagina.maxPag <= 0 ? 1 : pagina.maxPag;
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

  Future<void> _carregarMais() async {
    if (_loadingMore || _numPag >= _maxPag) return;
    setState(() => _loadingMore = true);
    try {
      final pagina = await listarExtrato(
        filtro: _filtro,
        pagina: _numPag + 1,
      );
      if (!mounted) return;
      setState(() {
        _itens.addAll(pagina.itens);
        _numPag = pagina.numPag;
        _maxPag = pagina.maxPag <= 0 ? _maxPag : pagina.maxPag;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _aplicarFiltro(ExtratoFiltro filtro) {
    if (_filtro.modo == filtro.modo &&
        _filtro.referencia == filtro.referencia &&
        _filtro.incluirCredito == filtro.incluirCredito) {
      return;
    }
    setState(() => _filtro = filtro);
    _carregar(forceRefresh: true, limpar: true);
  }

  String _rotuloPeriodo() {
    if (_filtro.modo == ExtratoModoFiltro.dia) {
      return rotuloDiaNavegacao(_filtro.referencia);
    }
    return '${_meses[_filtro.mes]} ${_filtro.ano}';
  }

  Future<void> _abrirPicker() async {
    final inicial = _filtro.modo == ExtratoModoFiltro.dia
        ? _filtro.referencia
        : DateTime(_filtro.ano, _filtro.mes, 1);
    final escolhido = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 2),
      helpText: _filtro.modo == ExtratoModoFiltro.dia
          ? 'Escolher dia'
          : 'Escolher mês',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme(
              brightness: Theme.of(context).brightness,
              primary: DinixColors.primary,
              onPrimary: DinixColors.onPrimary,
              secondary: DinixColors.secondary,
              onSecondary: DinixColors.onPrimary,
              error: AppColors.red,
              onError: Colors.white,
              surface: DinixColors.surfaceElevated,
              onSurface: DinixColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (escolhido == null || !mounted) return;
    if (_filtro.modo == ExtratoModoFiltro.dia) {
      _aplicarFiltro(
        ExtratoFiltro.dia(
          escolhido,
          incluirCredito: _filtro.incluirCredito,
        ),
      );
    } else {
      _aplicarFiltro(
        ExtratoFiltro.mes(
          escolhido.month,
          escolhido.year,
          incluirCredito: _filtro.incluirCredito,
        ),
      );
    }
  }

  Color _corTipo(String tipo) {
    switch (tipo) {
      case 'receita':
        return _corReceita;
      case 'despesa':
        return _corDespesa;
      case 'investimento':
        return _corInvest;
      case 'transferencia':
        return _corTransfer;
      default:
        return DinixColors.textPrimary;
    }
  }

  IconData _iconeTipo(String tipo) {
    switch (tipo) {
      case 'receita':
        return Phosphor.trendUp;
      case 'despesa':
        return Phosphor.trendDown;
      case 'investimento':
        return Phosphor.chartLineUp;
      case 'transferencia':
        return Phosphor.arrowsLeftRight;
      default:
        return Phosphor.circle;
    }
  }

  String _labelTipo(String tipo) {
    switch (tipo) {
      case 'receita':
        return 'Receita';
      case 'despesa':
        return 'Despesa';
      case 'investimento':
        return 'Investimento';
      case 'transferencia':
        return 'Transferência';
      default:
        return tipo;
    }
  }

  String _prefixoValor(TransacaoModel t) {
    if (t.isReceita) return '+';
    if (t.isDespesa) return '-';
    return '';
  }

  List<_LinhaExtrato> _montarLinhas() {
    final linhas = <_LinhaExtrato>[];
    String? diaAtual;
    for (final t in _itens) {
      final dia = (t.dataTransacao ?? '').length >= 10
          ? t.dataTransacao!.substring(0, 10)
          : '';
      if (dia.isNotEmpty && dia != diaAtual) {
        diaAtual = dia;
        linhas.add(_CabecalhoDia(dia));
      }
      linhas.add(_ItemTransacao(t));
    }
    return linhas;
  }

  Widget _chipModo(String label, ExtratoModoFiltro modo) {
    final ativo = _filtro.modo == modo;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (ativo) return;
            if (modo == ExtratoModoFiltro.mes) {
              _aplicarFiltro(
                ExtratoFiltro.mes(
                  _filtro.mes,
                  _filtro.ano,
                  incluirCredito: _filtro.incluirCredito,
                ),
              );
            } else {
              final agora = DateTime.now();
              final noMesAtual =
                  _filtro.mes == agora.month && _filtro.ano == agora.year;
              _aplicarFiltro(
                ExtratoFiltro.dia(
                  noMesAtual
                      ? agora
                      : DateTime(_filtro.ano, _filtro.mes, 1),
                  incluirCredito: _filtro.incluirCredito,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: ativo
                  ? DinixColors.primary.withValues(alpha: 0.18)
                  : DinixColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ativo
                    ? DinixColors.primary.withValues(alpha: 0.55)
                    : AppColors.grey800,
              ),
            ),
            alignment: Alignment.center,
            child: appText(
              label,
              bold: true,
              color: ativo ? DinixColors.primary : DinixColors.textPrimary,
              fontSize: AppFontSizes.verySmall,
            ),
          ),
        ),
      ),
    );
  }

  Widget _filtros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _chipModo('Mês', ExtratoModoFiltro.mes),
            appSizedBox(width: 10),
            _chipModo('Dia', ExtratoModoFiltro.dia),
          ],
        ),
        appSizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: () => _aplicarFiltro(_filtro.voltar()),
              icon: Icon(Phosphor.caretLeft, color: DinixColors.textPrimary),
              tooltip: _filtro.modo == ExtratoModoFiltro.dia
                  ? 'Dia anterior'
                  : 'Mês anterior',
            ),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _abrirPicker,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: appText(
                      _rotuloPeriodo(),
                      bold: true,
                      color: DinixColors.textPrimary,
                      fontSize: AppFontSizes.small,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _aplicarFiltro(_filtro.avancar()),
              icon: Icon(Phosphor.caretRight, color: DinixColors.textPrimary),
              tooltip: _filtro.modo == ExtratoModoFiltro.dia
                  ? 'Próximo dia'
                  : 'Próximo mês',
            ),
          ],
        ),
        appSizedBox(height: 4),
        Material(
          color: DinixColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => _aplicarFiltro(
              _filtro.copiarCom(incluirCredito: !_filtro.incluirCredito),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Phosphor.creditCard,
                    color: _filtro.incluirCredito
                        ? DinixColors.primary
                        : DinixColors.textMuted,
                    size: 20,
                  ),
                  appSizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        appText(
                          'Incluir gastos no crédito',
                          bold: true,
                          color: DinixColors.textPrimary,
                          fontSize: AppFontSizes.verySmall,
                        ),
                        appSizedBox(height: 2),
                        appText(
                          'Mostra cobranças feitas no cartão',
                          color: DinixColors.textMuted,
                          fontSize: 11,
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _filtro.incluirCredito,
                    activeThumbColor: DinixColors.primary,
                    onChanged: (v) => _aplicarFiltro(
                      _filtro.copiarCom(incluirCredito: v),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!_filtro.eMesAtual) ...[
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => _aplicarFiltro(
                ExtratoFiltro.mesAtual(
                  incluirCredito: _filtro.incluirCredito,
                ),
              ),
              child: appText(
                'Mês atual',
                color: DinixColors.primary,
                fontSize: AppFontSizes.verySmall,
                bold: true,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _cabecalhoDia(String dataIso) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: appText(
        rotuloDiaRelativo(dataIso),
        bold: true,
        color: DinixColors.textMuted,
        fontSize: AppFontSizes.verySmall,
      ),
    );
  }

  Widget _cardTransacao(TransacaoModel t) {
    final cor = _corTipo(t.tipo);
    final quando = dataHoraCobranca(t);
    final origem = origemTransacao(t, _lookups);
    final credito = !t.alteraSaldoConta;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DinixColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                credito ? Phosphor.creditCard : _iconeTipo(t.tipo),
                color: cor,
                size: 20,
              ),
            ),
            appSizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appText(
                    (t.descricao ?? '').trim().isEmpty
                        ? _labelTipo(t.tipo)
                        : t.descricao!.trim(),
                    bold: true,
                    color: DinixColors.textPrimary,
                    fontSize: AppFontSizes.small,
                    maxLines: 2,
                    overflow: true,
                  ),
                  if (quando.isNotEmpty) ...[
                    appSizedBox(height: 4),
                    appText(
                      quando,
                      color: DinixColors.textMuted,
                      fontSize: 11,
                    ),
                  ],
                  if (origem.isNotEmpty) ...[
                    appSizedBox(height: 2),
                    appText(
                      origem,
                      color: DinixColors.textPrimary.withValues(alpha: 0.75),
                      fontSize: 11,
                    ),
                  ],
                  appSizedBox(height: 3),
                  appText(
                    [
                      _labelTipo(t.tipo),
                      if (credito) 'Crédito',
                    ].join(' · '),
                    color: DinixColors.textMuted,
                    fontSize: 11,
                  ),
                ],
              ),
            ),
            appSizedBox(width: 8),
            appText(
              '${_prefixoValor(t)}${formataMoeda(t.valor)}',
              bold: true,
              color: cor,
              fontSize: AppFontSizes.small,
            ),
          ],
        ),
      ),
    );
  }

  Widget _lista() {
    final linhas = _montarLinhas();
    final extras = _loadingMore ? 1 : 0;

    if (_itens.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _filtros(),
          ),
          Expanded(
            child: listaRefreshVazia(
              context: context,
              onRefresh: () => _carregar(forceRefresh: true),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
              child: emptyMessage(
                title: 'Nenhuma movimentação',
                subtitle: _filtro.modo == ExtratoModoFiltro.dia
                    ? 'Não há lançamentos neste dia.'
                    : 'Não há lançamentos neste mês.',
                icon: Phosphor.listBullets,
              ),
            ),
          ),
        ],
      );
    }

    return listaRefreshBuilder(
      controller: _scroll,
      onRefresh: () => _carregar(forceRefresh: true),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: 1 + linhas.length + extras,
      itemBuilder: (_, index) {
        if (index == 0) return _filtros();
        final linhaIndex = index - 1;
        if (linhaIndex >= linhas.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: appLoadingDinix(size: 24),
          );
        }
        final linha = linhas[linhaIndex];
        return switch (linha) {
          _CabecalhoDia(:final dataIso) => _cabecalhoDia(dataIso),
          _ItemTransacao(:final transacao) => _cardTransacao(transacao),
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return dinixMenuScaffold(
      title: 'Extrato',
      body: _loading && _itens.isEmpty
          ? appLoadingDinix()
          : _erro != null && _itens.isEmpty
              ? appErrorState(
                  errorModel: _erro!,
                  subtitle: _erro!.mensagem ??
                      'Não foi possível carregar o extrato.',
                  onRetry: () => _carregar(forceRefresh: true),
                )
              : _lista(),
    );
  }
}

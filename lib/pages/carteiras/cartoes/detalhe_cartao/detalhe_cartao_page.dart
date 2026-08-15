import 'dart:convert';

import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/fatura_cartao_model.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cadastro_cartao/cadastro_cartao_page.dart';
import 'package:app_dinix/pages/carteiras/cartoes/detalhe_cartao/cadastro_fatura_cartao_page.dart';
import 'package:app_dinix/services/cartao_service.dart';
import 'package:app_dinix/services/fatura_cartao_service.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_error_state.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_select_sheet.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:app_dinix/widgets/empty.dart';
import 'package:app_dinix/widgets/lista_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class DetalheCartaoPage extends StatefulWidget {
  final CartaoCreditoModel cartao;

  const DetalheCartaoPage({super.key, required this.cartao});

  @override
  State<DetalheCartaoPage> createState() => _DetalheCartaoPageState();
}

class _DetalheCartaoPageState extends State<DetalheCartaoPage> {
  late CartaoCreditoModel _cartao;
  List<FaturaCartaoModel> _faturas = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _cartao = widget.cartao;
    _carregar();
  }

  Future<void> _carregar() async {
    final id = _cartao.id;
    if (id == null || id.isEmpty) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final cartaoResponse = await getCartaoPorId(id);
      final cartao = CartaoCreditoModel.fromMap(
        Map<String, dynamic>.from(jsonDecode(cartaoResponse.body) as Map),
      );
      final faturas = await listarFaturasCartao(id);
      if (!mounted) return;
      setState(() {
        _cartao = cartao;
        _faturas = faturas;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = e.toString();
      });
      showAppErrorFromException(e);
    }
  }

  Future<void> _abrirEditarCartao() async {
    final salvo = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (_) => CadastroCartaoPage(cartao: _cartao),
      ),
    );
    if (salvo == true && mounted) await _carregar();
  }

  Future<void> _abrirFatura({FaturaCartaoModel? fatura}) async {
    final id = _cartao.id;
    if (id == null) return;

    int? anoSugerido;
    int? mesSugerido;
    if (fatura == null && _faturas.isNotEmpty) {
      final ultima = _faturas.last;
      final proxima = DateTime(ultima.ano ?? 2026, (ultima.mes ?? 1) + 1);
      anoSugerido = proxima.year;
      mesSugerido = proxima.month;
    }

    final salvo = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (_) => CadastroFaturaCartaoPage(
          idCartao: id,
          fatura: fatura,
          anoSugerido: anoSugerido,
          mesSugerido: mesSugerido,
        ),
      ),
    );
    if (salvo == true && mounted) await _carregar();
  }

  Future<void> _fecharAtual() async {
    final id = _cartao.id;
    if (id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Fechar fatura atual',
      message:
          'A fatura atual será fechada e a próxima se tornará a fatura atual. Continuar?',
      confirmLabel: 'Fechar',
    );
    if (ok != true) return;
    try {
      await fecharFaturaAtual(id);
      showToastSuccess(message: 'Fatura fechada');
      await _carregar();
    } catch (e) {
      showAppErrorFromException(e);
    }
  }

  Future<void> _pagarFatura(FaturaCartaoModel fatura) async {
    final id = fatura.id;
    if (id == null) return;

    List<ContaModel> contas;
    try {
      final pagina = await listarContas(forceRefresh: true, pagina: 1);
      contas = pagina.itens;
    } catch (e) {
      showAppErrorFromException(e);
      return;
    }
    if (contas.isEmpty) {
      showToastWarning(message: 'Cadastre uma conta para registrar o pagamento.');
      return;
    }
    if (!mounted) return;

    final selecionada = await showAppSelectSheet<ContaModel>(
      context: context,
      title: 'Conta do pagamento',
      items: contas,
      labelOf: (c) => c.nomeBanco ?? c.nome ?? 'Conta',
      subtitleOf: (c) => formataMoeda(c.saldoAtual ?? c.saldoInicial),
      selected: contas.where((c) => c.id == _cartao.idConta).firstOrNull,
      leadingOf: (c) => bancoIcon(banco: c.nomeBanco ?? c.nome, size: 32),
    );
    if (selecionada == null || selecionada.id == null) return;
    if (!mounted) return;

    final ok = await showAppConfirmDialog(
      context,
      title: 'Marcar como paga',
      message:
          'Debitar ${formataMoeda(fatura.valor)} de ${selecionada.nomeBanco ?? selecionada.nome} '
          'e liberar o limite da fatura de ${fatura.rotuloMes}?',
      confirmLabel: 'Pagar',
    );
    if (ok != true) return;

    try {
      await pagarFaturaCartao(id, idConta: selecionada.id!);
      showToastSuccess(message: 'Fatura paga');
      await _carregar();
    } catch (e) {
      showAppErrorFromException(e);
    }
  }

  Future<void> _excluirFatura(FaturaCartaoModel fatura) async {
    final id = fatura.id;
    if (id == null || fatura.isAtual) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Remover fatura',
      message: 'Remover a fatura de ${fatura.rotuloMes}?',
      confirmLabel: 'Remover',
      destructive: true,
    );
    if (ok != true) return;
    try {
      await removerFaturaCartao(id);
      showToastSuccess(message: 'Fatura removida');
      await _carregar();
    } catch (e) {
      showAppErrorFromException(e);
    }
  }

  Widget _resumo() {
    final limite = _cartao.limite ?? 0;
    final usado = _cartao.limiteUsado ?? 0;
    final disponivel =
        _cartao.limiteDisponivel ?? (limite - usado).clamp(0.0, limite);

    return Material(
      color: DinixColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                bancoIcon(
                  banco: _cartao.banco,
                  fallback: _cartao.nome,
                  size: 42,
                ),
                appSizedBox(width: AppSpacing.normal),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      appText(
                        _cartao.nome ?? '',
                        bold: true,
                        color: DinixColors.textPrimary,
                        fontSize: AppFontSizes.normal,
                      ),
                      appText(
                        _cartao.banco ?? '',
                        color: AppColors.grey400,
                        fontSize: AppFontSizes.verySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            appSizedBox(height: AppSpacing.medium),
            appText(
              'Limite sobrando',
              color: AppColors.grey400,
              fontSize: AppFontSizes.verySmall,
            ),
            appSizedBox(height: 6),
            appText(
              formataMoeda(disponivel),
              bold: true,
              color: DinixColors.textPrimary,
              fontSize: 28,
            ),
            appSizedBox(height: 8),
            appText(
              '${formataMoeda(usado)} / ${formataMoeda(limite)}',
              color: AppColors.grey400,
              fontSize: AppFontSizes.verySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemFatura(FaturaCartaoModel fatura) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: fatura.isPaga ? null : () => _abrirFatura(fatura: fatura),
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      appText(
                        fatura.rotuloMes,
                        bold: true,
                        color: DinixColors.textPrimary,
                      ),
                      appSizedBox(height: 4),
                      appText(
                        fatura.rotuloStatus,
                        color: fatura.isAtual
                            ? DinixColors.primary
                            : AppColors.grey400,
                        fontSize: AppFontSizes.verySmall,
                      ),
                    ],
                  ),
                ),
                appText(
                  formataMoeda(fatura.valor),
                  bold: true,
                  color: DinixColors.textPrimary,
                  fontSize: AppFontSizes.medium,
                ),
                if (!fatura.isAtual && !fatura.isPaga) ...[
                  appSizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: Icon(Phosphor.dotsThreeVertical, color: AppColors.grey400),
                    color: DinixColors.surfaceElevated,
                    onSelected: (value) {
                      if (value == 'pagar') _pagarFatura(fatura);
                      if (value == 'excluir') _excluirFatura(fatura);
                    },
                    itemBuilder: (_) => [
                      if (fatura.isFechada)
                        const PopupMenuItem(
                          value: 'pagar',
                          child: Text('Marcar como paga'),
                        ),
                      if (!fatura.isAtual)
                        const PopupMenuItem(
                          value: 'excluir',
                          child: Text('Remover'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Cartão',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      drawerColor: DinixColors.textPrimary,
      actions: [
        IconButton(
          onPressed: _abrirEditarCartao,
          icon: Icon(Phosphor.pencilSimple, color: DinixColors.primary),
          tooltip: 'Editar cartão',
        ),
      ],
      body: _carregando
          ? appLoadingDinix()
          : _erro != null
              ? appErrorState(
                  subtitle: 'Não foi possível carregar o cartão.',
                  onRetry: _carregar,
                )
              : dinixRefresh(
                  onRefresh: _carregar,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _resumo(),
                      appSizedBox(height: AppSpacing.medium),
                      Row(
                        children: [
                          Expanded(
                            child: appText(
                              'Faturas',
                              bold: true,
                              color: DinixColors.textPrimary,
                              fontSize: AppFontSizes.small,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _abrirFatura(),
                            child: appText(
                              'Adicionar',
                              color: DinixColors.primary,
                              fontSize: AppFontSizes.verySmall,
                              bold: true,
                            ),
                          ),
                        ],
                      ),
                      appSizedBox(height: AppSpacing.small),
                      if (_faturas.isEmpty)
                        emptyMessage(
                          title: 'Nenhuma fatura',
                          subtitle:
                              'Adicione a fatura atual e as próximas para controlar o limite usado.',
                          icon: Phosphor.receipt,
                        )
                      else
                        ..._faturas.map(_itemFatura),
                      if (_faturas.any((f) => f.isAtual)) ...[
                        appSizedBox(height: AppSpacing.normal),
                        appElevatedButtonDinix(
                          title: 'Fechar fatura atual',
                          onTap: _fecharAtual,
                          primary: false,
                          height: 48,
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/apple_intelligence_bridge.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/gasto_mensal_model.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_service.dart';
import 'package:app_dinix/pages/gastos_mensais/gastos_mensais_service.dart';
import 'package:app_dinix/widgets/app_cadastro_style.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_select_sheet.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CadastroGastoMensalPage extends StatefulWidget {
  final GastoMensalModel? gasto;

  const CadastroGastoMensalPage({super.key, this.gasto});

  @override
  State<CadastroGastoMensalPage> createState() =>
      _CadastroGastoMensalPageState();
}

class _CadastroGastoMensalPageState extends State<CadastroGastoMensalPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();
  final FocusNode _valorFocus = FocusNode();

  late final AppFormField _nomeForm;
  late final bool _isEdit;

  bool _loading = true;
  List<ContaModel> _contas = [];
  List<CartaoCreditoModel> _cartoes = [];

  String _formaPagamento = FormaPagamento.pix;
  String? _idConta;
  String? _idCartao;
  int _diaPagar = 1;
  late DateTime _dataInicio;
  DateTime? _mesFinal;
  bool _pagoEsseMes = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.gasto?.id != null && widget.gasto!.id!.isNotEmpty;
    _formaPagamento = widget.gasto?.formaPagamento ?? FormaPagamento.pix;
    _idConta = widget.gasto?.idConta;
    _idCartao = widget.gasto?.idCartaoCredito;
    _diaPagar = widget.gasto?.diaVencimento ?? 1;
    if (_diaPagar < 1) _diaPagar = 1;
    if (_diaPagar > 31) _diaPagar = 31;
    _dataInicio = _parseData(widget.gasto?.dataInicio) ?? DateTime.now();
    _dataInicio = DateTime(_dataInicio.year, _dataInicio.month, _dataInicio.day);
    final fim = _parseData(widget.gasto?.dataFim);
    if (fim != null) {
      _mesFinal = DateTime(fim.year, fim.month, 1);
    }
    _criarCampos();
    _preencher();
    _valorFocus.addListener(_aoFocarValor);
    _carregarLookups();
    final id = widget.gasto?.id;
    if (id != null && id.isNotEmpty) {
      setAppleIntelligenceOnScreenEntity(
        type: AppleIntelligenceEntityType.gastoMensal,
        id: id,
        title: widget.gasto?.nome,
      );
    }
  }

  DateTime? _parseData(String? iso) {
    if (iso == null || iso.length < 10) return null;
    return DateTime.tryParse(iso.substring(0, 10));
  }

  void _aoFocarValor() {
    if (_valorFocus.hasFocus) return;
    normalizarValorCampo(_valorController);
  }

  void _criarCampos() {
    _nomeForm = criarCampoDinix(
      context: context,
      hint: 'Nome do gasto',
      icon: PhosphorFill.calendarBlank,
      validator: (v) => validateObrigatorio(v, campo: 'Nome'),
    );
  }

  void _preencher() {
    final item = widget.gasto;
    if (item?.valor != null) {
      _valorController.text = formataMoedaCampo(item!.valor);
    } else if (!_isEdit) {
      _valorController.text = formataMoedaCampo(kCadastroValorPadrao);
    }
    if (item == null) return;
    _nomeForm.controller.text = item.nome ?? '';
  }

  Future<void> _carregarLookups() async {
    try {
      final contas = await listarContas(forceRefresh: false);
      final cartoes = await listarCartoes(forceRefresh: false);
      if (!mounted) return;
      setState(() {
        _contas = contas.itens;
        _cartoes = cartoes.itens;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppErrorSnackbar(errorModelFromException(e));
    }
  }

  void _selecionarPagamento(String forma) {
    setState(() {
      _formaPagamento = forma;
      if (FormaPagamento.usaCartao(forma)) {
        _idConta = null;
      } else {
        _idCartao = null;
      }
    });
  }

  Future<void> _escolherDestino() async {
    if (FormaPagamento.usaCartao(_formaPagamento)) {
      if (_cartoes.isEmpty) {
        showToastWarning(message: 'Cadastre um cartão antes.');
        return;
      }
      final selecionado = await showAppSelectSheet<CartaoCreditoModel>(
        context: context,
        title: 'Cartão',
        items: _cartoes,
        labelOf: (c) => c.nome ?? '',
        subtitleOf: (c) => c.banco,
        selected: _cartoes.where((c) => c.id == _idCartao).firstOrNull,
        leadingOf: (c) => bancoIcon(banco: c.banco ?? c.nome, size: 32),
      );
      if (selecionado == null) return;
      setState(() => _idCartao = selecionado.id);
      return;
    }

    if (_contas.isEmpty) {
      showToastWarning(message: 'Cadastre uma conta antes.');
      return;
    }
    final selecionada = await showAppSelectSheet<ContaModel>(
      context: context,
      title: 'Conta',
      items: _contas,
      labelOf: (c) => c.nome ?? '',
      subtitleOf: (c) => c.nomeBanco,
      selected: _contas.where((c) => c.id == _idConta).firstOrNull,
      leadingOf: (c) => bancoIcon(banco: c.nomeBanco ?? c.nome, size: 32),
    );
    if (selecionada == null) return;
    setState(() => _idConta = selecionada.id);
  }

  Widget _campoDestino() {
    final credito = FormaPagamento.usaCartao(_formaPagamento);
    if (credito) {
      final cartao = _cartoes.where((c) => c.id == _idCartao).firstOrNull;
      return cadastroSecao(
        'Cartão',
        cadastroBotaoSeletor(
          tituloVazio: 'Selecionar cartão',
          valor: cartao?.nome,
          leading: cartao == null
              ? Icon(Phosphor.creditCard, color: DinixColors.primary)
              : bancoIcon(banco: cartao.banco ?? cartao.nome, size: 28),
          onTap: _escolherDestino,
        ),
      );
    }

    final conta = _contas.where((c) => c.id == _idConta).firstOrNull;
    return cadastroSecao(
      'Conta',
      cadastroBotaoSeletor(
        tituloVazio: 'Selecionar conta',
        valor: conta?.nome,
        leading: conta == null
            ? Icon(Phosphor.wallet, color: DinixColors.primary)
            : bancoIcon(banco: conta.nomeBanco ?? conta.nome, size: 28),
        onTap: _escolherDestino,
      ),
    );
  }

  String? _dataFimIso() {
    final mes = _mesFinal;
    if (mes == null) return null;
    final ultimo = DateTime(mes.year, mes.month + 1, 0);
    return dateTimeParaIso(ultimo);
  }

  Future<void> _salvar() async {
    if (!validarFormularioComFeedback(_formKey)) return;
    final credito = FormaPagamento.usaCartao(_formaPagamento);
    if (credito && (_idCartao == null || _idCartao!.isEmpty)) {
      showToastWarning(message: 'Selecione um cartão');
      return;
    }
    if (!credito && (_idConta == null || _idConta!.isEmpty)) {
      showToastWarning(message: 'Selecione uma conta');
      return;
    }

    final valor = (parseValor(_valorController.text) ?? kCadastroValorPadrao)
        .clamp(kCadastroValorMinimo, kCadastroValorMaximo)
        .toDouble();

    setState(() => _salvando = true);
    try {
      await salvarGastoMensal(
        GastoMensalModel(
          id: widget.gasto?.id,
          nome: _nomeForm.value.trim(),
          valor: valor,
          formaPagamento: _formaPagamento,
          idConta: credito ? null : _idConta,
          idCartaoCredito: credito ? _idCartao : null,
          diaVencimento: _diaPagar,
          dataInicio: dateTimeParaIso(_dataInicio),
          dataFim: _dataFimIso(),
          recorrencia: Recorrencia.mensal,
          pagamentoHoje: !_isEdit && _pagoEsseMes,
        ),
      );
      if (!mounted) return;
      showToastSuccess(
        message: _isEdit ? 'Gasto mensal atualizado' : 'Gasto mensal cadastrado',
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      showAppErrorSnackbar(errorModelFromException(e));
    }
  }

  Future<void> _excluir() async {
    final id = widget.gasto?.id;
    if (id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Excluir gasto mensal',
      message: 'O gasto deixará de aparecer nas cobranças. Deseja continuar?',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (ok != true) return;
    setState(() => _salvando = true);
    try {
      await removerGastoMensal(id);
      if (!mounted) return;
      showToastSuccess(message: 'Gasto mensal excluído');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      showAppErrorSnackbar(errorModelFromException(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: _isEdit ? 'Editar gasto mensal' : 'Novo gasto mensal',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.appBar,
      titleColor: DinixColors.onAppBar,
      drawerColor: DinixColors.onAppBar,
      body: _loading || _salvando
          ? appLoadingDinix()
          : Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  cadastroCampoValor(
                    titulo: 'Valor',
                    controller: _valorController,
                    focusNode: _valorFocus,
                    validator: validateValor,
                    onChanged: () => setState(() {}),
                  ),
                  cadastroSecao('Nome', _nomeForm.formulario),
                  cadastroSecao(
                    'Como será o pagamento',
                    cadastroGradeChips(
                      [
                        for (final forma in FormaPagamento.valores)
                          cadastroChip(
                            label: FormaPagamento.rotulo(forma),
                            selecionado: _formaPagamento == forma,
                            onTap: () => _selecionarPagamento(forma),
                          ),
                      ],
                      colunas: 2,
                    ),
                  ),
                  _campoDestino(),
                  cadastroCampoInteiro(
                    titulo: 'Data de pagar (dia)',
                    valor: _diaPagar,
                    min: 1,
                    max: 31,
                    onChanged: (v) => setState(() => _diaPagar = v),
                    rotulo: (v) => 'Dia $v',
                  ),
                  cadastroCampoQuando(
                    titulo: 'Início',
                    data: _dataInicio,
                    onChanged: (d) => setState(() => _dataInicio = d),
                  ),
                  cadastroSecao(
                    'Mês final (opcional)',
                    cadastroBotaoSeletor(
                      tituloVazio: 'Sem mês limite',
                      valor: _mesFinal == null
                          ? null
                          : '${_mesFinal!.month.toString().padLeft(2, '0')}/${_mesFinal!.year}',
                      leading: Icon(
                        Phosphor.calendarBlank,
                        color: DinixColors.primary,
                      ),
                      onTap: () async {
                        final agora = DateTime.now();
                        final escolhido = await showDatePicker(
                          context: context,
                          initialDate: _mesFinal ?? agora,
                          firstDate: DateTime(agora.year - 1),
                          lastDate: DateTime(agora.year + 20),
                          helpText: 'Escolha o mês final',
                        );
                        if (escolhido == null) return;
                        setState(() {
                          _mesFinal =
                              DateTime(escolhido.year, escolhido.month, 1);
                        });
                      },
                    ),
                  ),
                  if (_mesFinal != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _mesFinal = null),
                        child: appText(
                          'Remover mês final',
                          color: DinixColors.primary,
                          fontSize: AppFontSizes.verySmall,
                        ),
                      ),
                    ),
                  if (!_isEdit)
                    cadastroSwitch(
                      titulo: 'Pago esse mês',
                      subtitulo:
                          'Já registra o pagamento agora na conta ou cartão escolhido.',
                      value: _pagoEsseMes,
                      onChanged: (v) => setState(() => _pagoEsseMes = v),
                    ),
                  appSizedBox(height: AppSpacing.medium),
                  appElevatedButtonDinix(
                    title: _isEdit ? AppStrings.salvar : 'Cadastrar',
                    onTap: _salvar,
                    height: 52,
                  ),
                  if (_isEdit) ...[
                    appSizedBox(height: AppSpacing.normal),
                    appElevatedButtonDinix(
                      title: 'Excluir',
                      invertedStyle: true,
                      onTap: _excluir,
                      height: 52,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    clearAppleIntelligenceOnScreenEntity();
    _valorFocus.removeListener(_aoFocarValor);
    _valorController.dispose();
    _valorFocus.dispose();
    super.dispose();
  }
}

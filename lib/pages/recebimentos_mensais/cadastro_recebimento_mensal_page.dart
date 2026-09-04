import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/recebimento_mensal_model.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/pages/recebimentos_mensais/recebimentos_mensais_service.dart';
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

class CadastroRecebimentoMensalPage extends StatefulWidget {
  final RecebimentoMensalModel? recebimento;

  const CadastroRecebimentoMensalPage({super.key, this.recebimento});

  @override
  State<CadastroRecebimentoMensalPage> createState() =>
      _CadastroRecebimentoMensalPageState();
}

class _CadastroRecebimentoMensalPageState
    extends State<CadastroRecebimentoMensalPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();
  final FocusNode _valorFocus = FocusNode();

  late final AppFormField _nomeForm;
  late final bool _isEdit;

  bool _loading = true;
  List<ContaModel> _contas = [];

  String? _idConta;
  int _diaReceber = 1;
  late DateTime _dataInicio;
  DateTime? _mesFinal;
  bool _recebidoEsseMes = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _isEdit =
        widget.recebimento?.id != null && widget.recebimento!.id!.isNotEmpty;
    _idConta = widget.recebimento?.idConta;
    _diaReceber = widget.recebimento?.diaRecebimento ?? 1;
    if (_diaReceber < 1) _diaReceber = 1;
    if (_diaReceber > 31) _diaReceber = 31;
    _dataInicio =
        _parseData(widget.recebimento?.dataInicio) ?? DateTime.now();
    _dataInicio =
        DateTime(_dataInicio.year, _dataInicio.month, _dataInicio.day);
    final fim = _parseData(widget.recebimento?.dataFim);
    if (fim != null) {
      _mesFinal = DateTime(fim.year, fim.month, 1);
    }
    _criarCampos();
    _preencher();
    _valorFocus.addListener(_aoFocarValor);
    _carregarLookups();
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
      hint: 'Ex.: Salário',
      icon: PhosphorFill.trendUp,
      validator: (v) => validateObrigatorio(v, campo: 'Nome'),
    );
  }

  void _preencher() {
    final item = widget.recebimento;
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
      if (!mounted) return;
      setState(() {
        _contas = contas.itens;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppErrorSnackbar(errorModelFromException(e));
    }
  }

  Future<void> _escolherConta() async {
    if (_contas.isEmpty) {
      showToastWarning(message: 'Cadastre uma conta antes.');
      return;
    }
    final selecionada = await showAppSelectSheet<ContaModel>(
      context: context,
      title: 'Conta de destino',
      items: _contas,
      labelOf: (c) => c.nome ?? '',
      subtitleOf: (c) => TipoConta.rotulo(c.tipoConta),
      selected: _contas.where((c) => c.id == _idConta).firstOrNull,
      leadingOf: (c) => bancoIcon(banco: c.nomeBanco ?? c.nome, size: 32),
    );
    if (selecionada == null) return;
    setState(() => _idConta = selecionada.id);
  }

  String? _dataFimIso() {
    final mes = _mesFinal;
    if (mes == null) return null;
    final ultimo = DateTime(mes.year, mes.month + 1, 0);
    return dateTimeParaIso(ultimo);
  }

  Future<void> _salvar() async {
    if (!validarFormularioComFeedback(_formKey)) return;
    if (_idConta == null || _idConta!.isEmpty) {
      showToastWarning(message: 'Selecione a conta de destino');
      return;
    }

    final valor = (parseValor(_valorController.text) ?? kCadastroValorPadrao)
        .clamp(kCadastroValorMinimo, kCadastroValorMaximo)
        .toDouble();

    setState(() => _salvando = true);
    try {
      await salvarRecebimentoMensal(
        RecebimentoMensalModel(
          id: widget.recebimento?.id,
          nome: _nomeForm.value.trim(),
          valor: valor,
          idConta: _idConta,
          diaRecebimento: _diaReceber,
          dataInicio: dateTimeParaIso(_dataInicio),
          dataFim: _dataFimIso(),
          recorrencia: Recorrencia.mensal,
          recebimentoHoje: !_isEdit && _recebidoEsseMes,
        ),
      );
      if (!mounted) return;
      showToastSuccess(
        message: _isEdit
            ? 'Recebimento atualizado'
            : 'Recebimento mensal cadastrado',
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      showAppErrorSnackbar(errorModelFromException(e));
    }
  }

  Future<void> _excluir() async {
    final id = widget.recebimento?.id;
    if (id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Excluir recebimento',
      message: 'Ele deixará de entrar na projeção mensal. Continuar?',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (ok != true) return;
    setState(() => _salvando = true);
    try {
      await removerRecebimentoMensal(id);
      if (!mounted) return;
      showToastSuccess(message: 'Recebimento excluído');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      showAppErrorSnackbar(errorModelFromException(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final conta = _contas.where((c) => c.id == _idConta).firstOrNull;

    return scaffold(
      title: _isEdit ? 'Editar recebimento' : 'Novo recebimento mensal',
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
                    'Conta de destino',
                    cadastroBotaoSeletor(
                      tituloVazio: 'Selecionar conta',
                      valor: conta?.nome,
                      leading: conta == null
                          ? Icon(Phosphor.wallet, color: DinixColors.primary)
                          : bancoIcon(
                              banco: conta.nomeBanco ?? conta.nome,
                              size: 28,
                            ),
                      onTap: _escolherConta,
                    ),
                  ),
                  cadastroCampoInteiro(
                    titulo: 'Dia do recebimento',
                    valor: _diaReceber,
                    min: 1,
                    max: 31,
                    onChanged: (v) => setState(() => _diaReceber = v),
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
                      titulo: 'Recebido esse mês',
                      subtitulo:
                          'Já credita o valor agora na conta selecionada.',
                      value: _recebidoEsseMes,
                      onChanged: (v) => setState(() => _recebidoEsseMes = v),
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
    _valorFocus.removeListener(_aoFocarValor);
    _valorController.dispose();
    _valorFocus.dispose();
    super.dispose();
  }
}

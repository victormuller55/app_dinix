import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/categoria_icone.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/assinatura_model.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/pages/assinaturas/cadastro_assinatura/cadastro_assinatura_bloc.dart';
import 'package:app_dinix/pages/assinaturas/cadastro_assinatura/cadastro_assinatura_event.dart';
import 'package:app_dinix/pages/assinaturas/cadastro_assinatura/cadastro_assinatura_state.dart';
import 'package:app_dinix/widgets/app_cadastro_style.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_select_sheet.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CadastroAssinaturaPage extends StatefulWidget {
  final AssinaturaModel? assinatura;

  const CadastroAssinaturaPage({super.key, this.assinatura});

  @override
  State<CadastroAssinaturaPage> createState() => _CadastroAssinaturaPageState();
}

class _CadastroAssinaturaPageState extends State<CadastroAssinaturaPage> {
  final CadastroAssinaturaBloc bloc = CadastroAssinaturaBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();
  final FocusNode _valorFocus = FocusNode();

  late final AppFormField _nomeForm;
  late final bool _isEdit;

  CadastroAssinaturaLookups? _lookups;
  String? _idCategoria;
  String _formaPagamento = FormaPagamento.cartaoCredito;
  String? _idConta;
  String? _idCartao;
  String _recorrencia = Recorrencia.mensal;
  late DateTime _dataInicio;
  int _diaCobranca = 1;
  bool _pagamentoHoje = false;

  @override
  void initState() {
    super.initState();
    _isEdit =
        widget.assinatura?.id != null && widget.assinatura!.id!.isNotEmpty;
    _idCategoria = widget.assinatura?.idCategoria;
    _formaPagamento =
        widget.assinatura?.formaPagamento ?? FormaPagamento.cartaoCredito;
    _idConta = widget.assinatura?.idConta;
    _idCartao = widget.assinatura?.idCartaoCredito;
    _recorrencia = widget.assinatura?.recorrencia ?? Recorrencia.mensal;
    _diaCobranca = widget.assinatura?.diaCobranca ?? DateTime.now().day;
    if (_diaCobranca < 1) _diaCobranca = 1;
    if (_diaCobranca > 31) _diaCobranca = 31;
    _dataInicio = _parseDataInicial(widget.assinatura?.dataInicio);
    _criarCampos();
    _preencher();
    _valorFocus.addListener(_aoFocarValor);
    bloc.add(CadastroAssinaturaLoadEvent());
    if (!_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _valorFocus.requestFocus();
      });
    }
  }

  void _aoFocarValor() {
    if (_valorFocus.hasFocus) return;
    normalizarValorCampo(_valorController);
  }

  DateTime _parseDataInicial(String? iso) {
    final parsed = iso != null && iso.length >= 10
        ? DateTime.tryParse(iso.substring(0, 10))
        : null;
    if (parsed != null) return DateTime(parsed.year, parsed.month, parsed.day);
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day);
  }

  void _criarCampos() {
    _nomeForm = criarCampoDinix(
      context: context,
      hint: 'Nome da assinatura',
      icon: PhosphorFill.stack,
      validator: (v) => validateObrigatorio(v, campo: 'Nome'),
    );
  }

  void _preencher() {
    final item = widget.assinatura;
    if (item?.valor != null) {
      _valorController.text = formataMoedaCampo(item!.valor);
    } else if (!_isEdit) {
      _valorController.text = formataMoedaCampo(kCadastroValorPadrao);
    }
    if (item == null) return;
    _nomeForm.controller.text = item.nome ?? '';
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

  Future<void> _escolherCategoria() async {
    final items = _lookups?.categorias ?? [];
    if (items.isEmpty) return;
    final selecionada = await showAppSelectSheet<CategoriaModel>(
      context: context,
      title: 'Categoria',
      items: items,
      labelOf: (c) => c.nome ?? '',
      selected: items.where((c) => c.id == _idCategoria).firstOrNull,
      leadingOf: (c) => Icon(iconeDaCategoria(c), color: DinixColors.primary),
    );
    if (selecionada == null) return;
    setState(() => _idCategoria = selecionada.id);
  }

  Future<void> _escolherDestinoPagamento() async {
    if (FormaPagamento.usaCartao(_formaPagamento)) {
      final items = _lookups?.cartoes ?? [];
      if (items.isEmpty) {
        showToastWarning(message: 'Cadastre um cartão antes.');
        return;
      }
      final selecionado = await showAppSelectSheet<CartaoCreditoModel>(
        context: context,
        title: 'Cartão',
        items: items,
        labelOf: (c) => c.nome ?? '',
        subtitleOf: (c) => c.banco,
        selected: items.where((c) => c.id == _idCartao).firstOrNull,
        leadingOf: (c) => bancoIcon(banco: c.banco ?? c.nome, size: 32),
      );
      if (selecionado == null) return;
      setState(() => _idCartao = selecionado.id);
      return;
    }

    final items = _lookups?.contas ?? [];
    if (items.isEmpty) {
      showToastWarning(message: 'Cadastre uma conta antes.');
      return;
    }
    final selecionada = await showAppSelectSheet<ContaModel>(
      context: context,
      title: 'Conta',
      items: items,
      labelOf: (c) => c.nome ?? '',
      subtitleOf: (c) => c.nomeBanco,
      selected: items.where((c) => c.id == _idConta).firstOrNull,
      leadingOf: (c) => bancoIcon(banco: c.nomeBanco ?? c.nome, size: 32),
    );
    if (selecionada == null) return;
    setState(() => _idConta = selecionada.id);
  }

  Widget _campoDestino() {
    final credito = FormaPagamento.usaCartao(_formaPagamento);
    if (credito) {
      final cartao =
          _lookups?.cartoes.where((c) => c.id == _idCartao).firstOrNull;
      return cadastroSecao(
        'Cartão',
        cadastroBotaoSeletor(
          tituloVazio: 'Selecionar cartão',
          valor: cartao?.nome,
          leading: cartao == null
              ? Icon(Phosphor.creditCard, color: DinixColors.primary)
              : bancoIcon(banco: cartao.banco ?? cartao.nome, size: 28),
          onTap: _escolherDestinoPagamento,
        ),
      );
    }

    final conta = _lookups?.contas.where((c) => c.id == _idConta).firstOrNull;
    return cadastroSecao(
      'Conta',
      cadastroBotaoSeletor(
        tituloVazio: 'Selecionar conta',
        valor: conta?.nome,
        leading: conta == null
            ? Icon(Phosphor.wallet, color: DinixColors.primary)
            : bancoIcon(banco: conta.nomeBanco ?? conta.nome, size: 28),
        onTap: _escolherDestinoPagamento,
      ),
    );
  }

  void _salvarCadastro() {
    if (!validarFormularioComFeedback(_formKey)) return;
    if (_idCategoria == null || _idCategoria!.isEmpty) {
      showToastWarning(message: 'Selecione uma categoria');
      return;
    }
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

    bloc.add(
      CadastroAssinaturaSaveEvent(
        assinatura: AssinaturaModel(
          id: widget.assinatura?.id,
          nome: _nomeForm.value.trim(),
          valor: valor,
          idCategoria: _idCategoria,
          formaPagamento: _formaPagamento,
          idConta: credito ? null : _idConta,
          idCartaoCredito: credito ? _idCartao : null,
          diaCobranca: _diaCobranca,
          dataInicio: dateTimeParaIso(_dataInicio),
          recorrencia: _recorrencia,
          pagamentoHoje: !_isEdit && _pagamentoHoje,
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao() async {
    final id = widget.assinatura?.id;
    if (id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Cancelar assinatura',
      message: 'A assinatura será cancelada. Deseja continuar?',
      confirmLabel: 'Cancelar assinatura',
      destructive: true,
    );
    if (ok == true) bloc.add(CadastroAssinaturaDeleteEvent(id: id));
  }

  void _onState(CadastroAssinaturaState state) {
    if (state is CadastroAssinaturaReadyState) {
      setState(() => _lookups = state.lookups);
    }
    if (state is CadastroAssinaturaSuccessState) {
      showToastSuccess(
        message: _isEdit ? 'Assinatura atualizada' : 'Assinatura cadastrada',
      );
      Navigator.of(context).pop(true);
    }
    if (state is CadastroAssinaturaDeletedState) {
      showToastSuccess(message: 'Assinatura cancelada');
      Navigator.of(context).pop(true);
    }
    if (state is CadastroAssinaturaErrorState) {
      showAppErrorSnackbar(state.errorModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoria =
        _lookups?.categorias.where((c) => c.id == _idCategoria).firstOrNull;

    return scaffold(
      title: _isEdit ? 'Editar assinatura' : 'Nova assinatura',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      drawerColor: DinixColors.textPrimary,
      body: BlocConsumer<CadastroAssinaturaBloc, CadastroAssinaturaState>(
        bloc: bloc,
        listener: (_, state) => _onState(state),
        builder: (context, state) {
          if (state is CadastroAssinaturaLoadingState ||
              state is CadastroAssinaturaInitialState) {
            return appLoadingDinix();
          }
          return Form(
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
                  'Categoria',
                  cadastroBotaoSeletor(
                    tituloVazio: 'Selecionar categoria',
                    valor: categoria?.nome,
                    leading: Icon(
                      iconeDaCategoria(categoria),
                      color: DinixColors.primary,
                    ),
                    onTap: _escolherCategoria,
                  ),
                ),
                cadastroSecao(
                  'Pagamento',
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
                  titulo: 'Dia da cobrança',
                  valor: _diaCobranca,
                  min: 1,
                  max: 31,
                  onChanged: (v) => setState(() => _diaCobranca = v),
                  rotulo: (v) => 'Dia $v',
                ),
                cadastroCampoQuando(
                  titulo: 'Início',
                  data: _dataInicio,
                  onChanged: (d) => setState(() => _dataInicio = d),
                ),
                if (!_isEdit)
                  cadastroSwitch(
                    titulo: 'Pagamento foi hoje',
                    subtitulo:
                        'Cobra agora na conta ou cartão selecionado. Se desmarcado, a cobrança ocorre na data de cobrança.',
                    value: _pagamentoHoje,
                    onChanged: (v) => setState(() {
                      _pagamentoHoje = v;
                      if (v) {
                        final agora = DateTime.now();
                        _dataInicio =
                            DateTime(agora.year, agora.month, agora.day);
                      }
                    }),
                  ),
                cadastroSecao(
                  'Recorrência',
                  cadastroGradeChips(
                    [
                      for (final item in Recorrencia.valores)
                        cadastroChip(
                          label: Recorrencia.rotulo(item),
                          selecionado: _recorrencia == item,
                          onTap: () => setState(() => _recorrencia = item),
                        ),
                    ],
                    colunas: 2,
                  ),
                ),
                appSizedBox(height: AppSpacing.medium),
                appElevatedButtonDinix(
                  title: _isEdit ? AppStrings.salvar : 'Cadastrar',
                  onTap: _salvarCadastro,
                  height: 52,
                ),
                if (_isEdit) ...[
                  appSizedBox(height: AppSpacing.normal),
                  appElevatedButtonDinix(
                    title: 'Cancelar assinatura',
                    invertedStyle: true,
                    onTap: _confirmarExclusao,
                    height: 52,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _valorFocus.removeListener(_aoFocarValor);
    _valorController.dispose();
    _valorFocus.dispose();
    bloc.close();
    super.dispose();
  }
}

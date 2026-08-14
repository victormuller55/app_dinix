import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
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
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_select_sheet.dart';
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

  late final AppFormField _nomeForm;
  late final AppFormField _valorForm;
  late final AppFormField _categoriaForm;
  late final AppFormField _pagamentoForm;
  late final AppFormField _contaForm;
  late final AppFormField _diaForm;
  late final AppFormField _inicioForm;
  late final AppFormField _recorrenciaForm;
  late final bool _isEdit;

  CadastroAssinaturaLookups? _lookups;
  String? _idCategoria;
  String _formaPagamento = FormaPagamento.cartaoCredito;
  String? _idConta;
  String? _idCartao;
  String _recorrencia = Recorrencia.mensal;
  bool _pagamentoHoje = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.assinatura?.id != null && widget.assinatura!.id!.isNotEmpty;
    _idCategoria = widget.assinatura?.idCategoria;
    _formaPagamento = widget.assinatura?.formaPagamento ?? FormaPagamento.cartaoCredito;
    _idConta = widget.assinatura?.idConta;
    _idCartao = widget.assinatura?.idCartaoCredito;
    _recorrencia = widget.assinatura?.recorrencia ?? Recorrencia.mensal;
    _criarCampos();
    _preencher();
    bloc.add(CadastroAssinaturaLoadEvent());
  }

  void _criarCampos() {
    _nomeForm = criarCampoDinix(
      context: context,
      hint: 'Nome',
      icon: PhosphorFill.stack,
      validator: (v) => validateObrigatorio(v, campo: 'Nome'),
    );
    _valorForm = criarCampoDinix(
      context: context,
      hint: 'Valor',
      icon: Phosphor.money,
      textInputType: const TextInputType.numberWithOptions(decimal: true),
      validator: validateValor,
    );
    _categoriaForm = criarCampoDinix(
      context: context,
      hint: 'Categoria',
      icon: Phosphor.tag,
      showKeyboard: false,
      onTap: _escolherCategoria,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
      validator: (v) => validateObrigatorio(v, campo: 'Categoria'),
    );
    _pagamentoForm = criarCampoDinix(
      context: context,
      hint: 'Forma de pagamento',
      icon: Phosphor.wallet,
      showKeyboard: false,
      onTap: _escolherPagamento,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
    );
    _contaForm = criarCampoDinix(
      context: context,
      hint: FormaPagamento.usaCartao(_formaPagamento) ? 'Cartão' : 'Conta',
      icon: Phosphor.wallet,
      showKeyboard: false,
      onTap: _escolherDestinoPagamento,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
      validator: (v) => validateObrigatorio(v, campo: 'Pagamento'),
    );
    _diaForm = criarCampoDinix(
      context: context,
      hint: 'Dia da cobrança',
      icon: Phosphor.calendar,
      textInputType: TextInputType.number,
      validator: validateDiaMes,
    );
    _inicioForm = criarCampoDinix(
      context: context,
      hint: 'Data de início',
      icon: Phosphor.calendarBlank,
      textInputFormatter: AppFormFormatters.data,
      textInputType: TextInputType.number,
      validator: validateDataBr,
    );
    _recorrenciaForm = criarCampoDinix(
      context: context,
      hint: 'Recorrência',
      icon: Phosphor.arrowsClockwise,
      showKeyboard: false,
      onTap: _escolherRecorrencia,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
    );
  }

  void _preencher() {
    final item = widget.assinatura;
    _pagamentoForm.controller.text = FormaPagamento.rotulo(_formaPagamento);
    _recorrenciaForm.controller.text = Recorrencia.rotulo(_recorrencia);
    _inicioForm.controller.text = isoParaBr(item?.dataInicio ?? dataHojeIso());
    if (item == null) return;
    _nomeForm.controller.text = item.nome ?? '';
    if (item.valor != null) _valorForm.controller.text = item.valor!.toStringAsFixed(2);
    _diaForm.controller.text = '${item.diaCobranca ?? ''}';
  }

  void _aplicarLookups(CadastroAssinaturaLookups lookups) {
    _lookups = lookups;
    final categoria = lookups.categorias.where((c) => c.id == _idCategoria).firstOrNull;
    if (categoria != null) _categoriaForm.controller.text = categoria.nome ?? '';
    _atualizarDestinoLabel();
  }

  void _atualizarDestinoLabel() {
    if (FormaPagamento.usaCartao(_formaPagamento)) {
      final cartao = _lookups?.cartoes.where((c) => c.id == _idCartao).firstOrNull;
      _contaForm.controller.text = cartao?.nome ?? '';
    } else {
      final conta = _lookups?.contas.where((c) => c.id == _idConta).firstOrNull;
      _contaForm.controller.text = conta?.nome ?? '';
    }
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
    );
    if (selecionada == null) return;
    setState(() {
      _idCategoria = selecionada.id;
      _categoriaForm.controller.text = selecionada.nome ?? '';
    });
  }

  Future<void> _escolherPagamento() async {
    final selecionada = await showAppSelectSheet<String>(
      context: context,
      title: 'Forma de pagamento',
      items: FormaPagamento.valores,
      labelOf: FormaPagamento.rotulo,
      selected: _formaPagamento,
    );
    if (selecionada == null) return;
    setState(() {
      _formaPagamento = selecionada;
      _pagamentoForm.controller.text = FormaPagamento.rotulo(selecionada);
      if (FormaPagamento.usaCartao(selecionada)) {
        _idConta = null;
      } else {
        _idCartao = null;
      }
      _atualizarDestinoLabel();
    });
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
        selected: items.where((c) => c.id == _idCartao).firstOrNull,
      );
      if (selecionado == null) return;
      setState(() {
        _idCartao = selecionado.id;
        _contaForm.controller.text = selecionado.nome ?? '';
      });
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
      selected: items.where((c) => c.id == _idConta).firstOrNull,
    );
    if (selecionada == null) return;
    setState(() {
      _idConta = selecionada.id;
      _contaForm.controller.text = selecionada.nome ?? '';
    });
  }

  Future<void> _escolherRecorrencia() async {
    final selecionada = await showAppSelectSheet<String>(
      context: context,
      title: 'Recorrência',
      items: Recorrencia.valores,
      labelOf: Recorrencia.rotulo,
      selected: _recorrencia,
    );
    if (selecionada == null) return;
    setState(() {
      _recorrencia = selecionada;
      _recorrenciaForm.controller.text = Recorrencia.rotulo(selecionada);
    });
  }

  void _salvarCadastro() {
    if (!validarFormularioComFeedback(_formKey)) return;
    final credito = FormaPagamento.usaCartao(_formaPagamento);
    bloc.add(
      CadastroAssinaturaSaveEvent(
        assinatura: AssinaturaModel(
          id: widget.assinatura?.id,
          nome: _nomeForm.value.trim(),
          valor: parseValor(_valorForm.value),
          idCategoria: _idCategoria,
          formaPagamento: _formaPagamento,
          idConta: credito ? null : _idConta,
          idCartaoCredito: credito ? _idCartao : null,
          diaCobranca: int.tryParse(_diaForm.value.trim()),
          dataInicio: brParaIso(_inicioForm.value),
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
    if (state is CadastroAssinaturaReadyState) _aplicarLookups(state.lookups);
    if (state is CadastroAssinaturaSuccessState) {
      showToastSuccess(message: _isEdit ? 'Assinatura atualizada' : 'Assinatura cadastrada');
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
          if (state is CadastroAssinaturaLoadingState || state is CadastroAssinaturaInitialState) {
            return appLoadingDinix();
          }
          return Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _nomeForm.formulario,
                _valorForm.formulario,
                _categoriaForm.formulario,
                _pagamentoForm.formulario,
                _contaForm.formulario,
                _diaForm.formulario,
                _inicioForm.formulario,
                if (!_isEdit)
                  SwitchListTile(
                    value: _pagamentoHoje,
                    activeThumbColor: DinixColors.primary,
                    title: appText(
                      'Pagamento foi hoje',
                      color: DinixColors.textPrimary,
                    ),
                    subtitle: appText(
                      'Cobra agora na conta ou cartão selecionado. Se desmarcado, a cobrança ocorre na data de cobrança.',
                      color: AppColors.grey400,
                      fontSize: AppFontSizes.verySmall,
                    ),
                    onChanged: (v) => setState(() {
                      _pagamentoHoje = v;
                      if (v) {
                        _inicioForm.controller.text = isoParaBr(dataHojeIso());
                      }
                    }),
                  ),
                _recorrenciaForm.formulario,
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
    bloc.close();
    super.dispose();
  }
}

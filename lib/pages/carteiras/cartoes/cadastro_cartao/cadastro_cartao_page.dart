import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cadastro_cartao/cadastro_cartao_bloc.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cadastro_cartao/cadastro_cartao_event.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cadastro_cartao/cadastro_cartao_state.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_select_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CadastroCartaoPage extends StatefulWidget {
  final CartaoCreditoModel? cartao;

  const CadastroCartaoPage({super.key, this.cartao});

  @override
  State<CadastroCartaoPage> createState() => _CadastroCartaoPageState();
}

class _CadastroCartaoPageState extends State<CadastroCartaoPage> {
  final CadastroCartaoBloc bloc = CadastroCartaoBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AppFormField _nomeForm;
  late final AppFormField _bancoForm;
  late final AppFormField _contaForm;
  late final AppFormField _limiteForm;
  late final AppFormField _fechamentoForm;
  late final AppFormField _vencimentoForm;
  late final bool _isEdit;

  List<ContaModel> _contas = [];
  String? _idConta;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.cartao?.id != null && widget.cartao!.id!.isNotEmpty;
    _idConta = widget.cartao?.idConta;
    _criarCampos();
    _preencher();
    bloc.add(CadastroCartaoLoadEvent());
  }

  void _criarCampos() {
    _nomeForm = criarCampoDinix(
      context: context,
      hint: 'Nome do cartão',
      icon: Phosphor.creditCard,
      validator: (v) => validateObrigatorio(v, campo: 'Nome'),
    );
    _bancoForm = criarCampoDinix(
      context: context,
      hint: 'Banco',
      icon: Phosphor.bank,
      validator: (v) => validateObrigatorio(v, campo: 'Banco'),
    );
    _contaForm = criarCampoDinix(
      context: context,
      hint: 'Conta de pagamento',
      icon: Phosphor.wallet,
      showKeyboard: false,
      onTap: _escolherConta,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
      validator: (v) => validateObrigatorio(v, campo: 'Conta'),
    );
    _limiteForm = criarCampoDinix(
      context: context,
      hint: 'Limite',
      icon: Phosphor.money,
      textInputType: const TextInputType.numberWithOptions(decimal: true),
      validator: validateValor,
    );
    _fechamentoForm = criarCampoDinix(
      context: context,
      hint: 'Dia de fechamento',
      icon: Phosphor.calendar,
      textInputType: TextInputType.number,
      validator: validateDiaMes,
    );
    _vencimentoForm = criarCampoDinix(
      context: context,
      hint: 'Dia de vencimento',
      icon: Phosphor.calendarCheck,
      textInputType: TextInputType.number,
      validator: validateDiaMes,
    );
  }

  void _preencher() {
    final cartao = widget.cartao;
    if (cartao == null) return;
    _nomeForm.controller.text = cartao.nome ?? '';
    _bancoForm.controller.text = cartao.banco ?? '';
    if (cartao.limite != null) {
      _limiteForm.controller.text = cartao.limite!.toStringAsFixed(2);
    }
    _fechamentoForm.controller.text = '${cartao.diaFechamento ?? ''}';
    _vencimentoForm.controller.text = '${cartao.diaVencimento ?? ''}';
  }

  void _aplicarContas(List<ContaModel> contas) {
    _contas = contas;
    if (_idConta != null) {
      final conta = contas.where((c) => c.id == _idConta).firstOrNull;
      if (conta != null) _contaForm.controller.text = conta.nome ?? '';
    }
  }

  Future<void> _escolherConta() async {
    if (_contas.isEmpty) {
      showToastWarning(message: 'Cadastre uma conta antes de criar o cartão.');
      return;
    }
    final selecionada = await showAppSelectSheet<ContaModel>(
      context: context,
      title: 'Conta de pagamento',
      items: _contas,
      labelOf: (c) => c.nome ?? '',
      selected: _contas.where((c) => c.id == _idConta).firstOrNull,
    );
    if (selecionada == null) return;
    setState(() {
      _idConta = selecionada.id;
      _contaForm.controller.text = selecionada.nome ?? '';
    });
  }

  void _salvarCadastro() {
    if (!validarFormularioComFeedback(_formKey)) return;
    if (_idConta == null || _idConta!.isEmpty) {
      showToastWarning(message: 'Selecione a conta de pagamento da fatura.');
      return;
    }
    bloc.add(
      CadastroCartaoSaveEvent(
        cartao: CartaoCreditoModel(
          id: widget.cartao?.id,
          idConta: _idConta,
          nome: _nomeForm.value.trim(),
          banco: _bancoForm.value.trim(),
          limite: parseValor(_limiteForm.value),
          diaFechamento: int.tryParse(_fechamentoForm.value.trim()),
          diaVencimento: int.tryParse(_vencimentoForm.value.trim()),
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao() async {
    final id = widget.cartao?.id;
    if (id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Remover cartão',
      message: 'Este cartão será removido. Deseja continuar?',
      confirmLabel: 'Remover',
      destructive: true,
    );
    if (ok == true) bloc.add(CadastroCartaoDeleteEvent(id: id));
  }

  void _onState(CadastroCartaoState state) {
    if (state is CadastroCartaoReadyState) {
      _aplicarContas(state.contas);
    }
    if (state is CadastroCartaoSuccessState) {
      showToastSuccess(message: _isEdit ? 'Cartão atualizado' : 'Cartão cadastrado');
      Navigator.of(context).pop(true);
    }
    if (state is CadastroCartaoDeletedState) {
      showToastSuccess(message: 'Cartão removido');
      Navigator.of(context).pop(true);
    }
    if (state is CadastroCartaoErrorState) {
      showAppErrorSnackbar(state.errorModel);
    }
  }

  Widget _formulario() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _nomeForm.formulario,
          _bancoForm.formulario,
          _contaForm.formulario,
          _limiteForm.formulario,
          _fechamentoForm.formulario,
          _vencimentoForm.formulario,
          appSizedBox(height: AppSpacing.medium),
          appElevatedButtonDinix(
            title: _isEdit ? AppStrings.salvar : 'Cadastrar',
            onTap: _salvarCadastro,
            height: 52,
          ),
          if (_isEdit) ...[
            appSizedBox(height: AppSpacing.normal),
            appElevatedButtonDinix(
              title: 'Remover',
              invertedStyle: true,
              onTap: _confirmarExclusao,
              height: 52,
            ),
          ],
        ],
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocConsumer<CadastroCartaoBloc, CadastroCartaoState>(
      bloc: bloc,
      listener: (_, state) => _onState(state),
      builder: (context, state) {
        if (state is CadastroCartaoLoadingState || state is CadastroCartaoInitialState) {
          return appLoadingDinix();
        }
        if (state is CadastroCartaoErrorState && _contas.isEmpty) {
          return Center(
            child: appElevatedButtonDinix(
              title: 'Tentar novamente',
              onTap: () => bloc.add(CadastroCartaoLoadEvent()),
            ),
          );
        }
        return _formulario();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: _isEdit ? 'Editar cartão' : 'Novo cartão',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      drawerColor: DinixColors.textPrimary,
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}

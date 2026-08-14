import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/bancos_catalogo.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/pages/carteiras/cadastro_conta/cadastro_conta_bloc.dart';
import 'package:app_dinix/pages/carteiras/cadastro_conta/cadastro_conta_event.dart';
import 'package:app_dinix/pages/carteiras/cadastro_conta/cadastro_conta_state.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_select_sheet.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:app_dinix/widgets/banco_select_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CadastroContaPage extends StatefulWidget {
  final ContaModel? conta;

  const CadastroContaPage({super.key, this.conta});

  @override
  State<CadastroContaPage> createState() => _CadastroContaPageState();
}

class _CadastroContaPageState extends State<CadastroContaPage> {
  final CadastroContaBloc bloc = CadastroContaBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _bancoController;
  late final FocusNode _bancoFocus;
  late final AppFormField _tipoForm;
  late final AppFormField _saldoForm;
  late final bool _isEdit;
  String _tipoConta = TipoConta.contaCorrente;
  BancoOpcao? _banco;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.conta?.id != null && widget.conta!.id!.isNotEmpty;
    _tipoConta = widget.conta?.tipoConta ?? TipoConta.contaCorrente;
    _banco = _resolverBanco(widget.conta?.nomeBanco);
    _bancoController = TextEditingController();
    _bancoFocus = FocusNode()..canRequestFocus = false;
    _criarCampos();
    _preencher();
  }

  BancoOpcao? _resolverBanco(String? nome) {
    final catalogo = BancosCatalogo.porNome(nome);
    if (catalogo != null) return catalogo;
    if (nome == null || nome.trim().isEmpty) return null;
    return BancoOpcao(
      nome: nome.trim(),
      cor: widget.conta?.cor ?? '#FF9800',
    );
  }

  Widget _prefixoBanco() {
    if (_banco == null) {
      return Icon(Phosphor.bank, size: 22, color: DinixColors.primary);
    }
    return Padding(
      padding: const EdgeInsets.all(10),
      child: bancoIcon(
        banco: _banco!.nome,
        size: 28,
        gradient: _banco!.gradiente,
      ),
    );
  }

  void _criarCampos() {
    _tipoForm = criarCampoDinix(
      context: context,
      hint: 'Tipo de conta',
      icon: Phosphor.tag,
      showKeyboard: false,
      onTap: _escolherTipo,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
    );
    _saldoForm = criarCampoDinix(
      context: context,
      hint: 'Saldo atual',
      icon: Phosphor.money,
      textInputType: TextInputType.number,
      textInputFormatter: MoedaInputFormatter(),
      validator: validateValorOpcional,
    );
  }

  void _preencher() {
    final conta = widget.conta;
    _bancoController.text = _banco?.nome ?? '';
    _tipoForm.controller.text = TipoConta.rotulo(_tipoConta);
    if (conta == null) return;
    final saldo = conta.saldoAtual ?? conta.saldoInicial;
    if (saldo != null) {
      _saldoForm.controller.text = formataMoedaCampo(saldo);
    }
  }

  Future<void> _escolherBanco() async {
    final selecionado = await showBancoSelectSheet(
      context: context,
      selected: _banco,
    );
    if (selecionado == null) return;
    setState(() {
      _banco = selecionado;
      _bancoController.text = selecionado.nome;
    });
  }

  Widget _campoBanco() {
    return CampoPrefixoDinix(
      controller: _bancoController,
      focusNode: _bancoFocus,
      hint: 'Banco',
      prefixIcon: _prefixoBanco(),
      onTap: _escolherBanco,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
    );
  }

  Future<void> _escolherTipo() async {
    final selecionado = await showAppSelectSheet<String>(
      context: context,
      title: 'Tipo de conta',
      items: TipoConta.valores,
      labelOf: TipoConta.rotulo,
      selected: _tipoConta,
    );
    if (selecionado == null) return;
    setState(() {
      _tipoConta = selecionado;
      _tipoForm.controller.text = TipoConta.rotulo(selecionado);
    });
  }

  String? _validarBanco(String? _) {
    if (_banco == null) return 'Selecione o banco';
    return null;
  }

  void _salvarCadastro() {
    if (_banco == null) {
      showToastWarning(message: 'Selecione o banco');
      return;
    }
    if (!validarFormularioComFeedback(_formKey)) return;
    final saldo = parseValor(_saldoForm.value) ?? 0;
    bloc.add(
      CadastroContaSaveEvent(
        conta: ContaModel(
          id: widget.conta?.id,
          nome: _banco!.nome,
          nomeBanco: _banco!.nome,
          tipoConta: _tipoConta,
          saldoAtual: saldo,
          cor: _banco!.cor,
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao() async {
    final id = widget.conta?.id;
    if (id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Remover conta',
      message: 'Esta conta será removida. Deseja continuar?',
      confirmLabel: 'Remover',
      destructive: true,
    );
    if (ok == true) {
      bloc.add(CadastroContaDeleteEvent(id: id));
    }
  }

  void _onState(CadastroContaState state) {
    if (state is CadastroContaSuccessState) {
      showToastSuccess(
        message: _isEdit ? 'Conta atualizada' : 'Conta cadastrada',
      );
      Navigator.of(context).pop(true);
    }
    if (state is CadastroContaDeletedState) {
      showToastSuccess(message: 'Conta removida');
      Navigator.of(context).pop(true);
    }
    if (state is CadastroContaErrorState) {
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
          FormField<String>(
            validator: _validarBanco,
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _campoBanco(),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 6),
                      child: appText(
                        state.errorText ?? '',
                        color: AppColors.red,
                        fontSize: AppFontSizes.verySmall,
                      ),
                    ),
                ],
              );
            },
          ),
          _tipoForm.formulario,
          _saldoForm.formulario,
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
    return BlocConsumer<CadastroContaBloc, CadastroContaState>(
      bloc: bloc,
      listener: (_, state) => _onState(state),
      builder: (context, state) {
        if (state is CadastroContaLoadingState) return appLoadingDinix();
        return _formulario();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: _isEdit ? 'Editar conta' : 'Nova conta',
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
    _bancoController.dispose();
    _bancoFocus.dispose();
    bloc.close();
    super.dispose();
  }
}

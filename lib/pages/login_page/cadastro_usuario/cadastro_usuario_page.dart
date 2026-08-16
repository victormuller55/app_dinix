import 'package:app_dinix/app_config/app_theme.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/pages/login_page/cadastro_usuario/cadastro_usuario_bloc.dart';
import 'package:app_dinix/pages/login_page/cadastro_usuario/cadastro_usuario_event.dart';
import 'package:app_dinix/pages/login_page/cadastro_usuario/cadastro_usuario_state.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/login/login_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final CadastroUsuarioBloc bloc = CadastroUsuarioBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final LoginFormField _nomeForm;
  late final LoginFormField _emailForm;
  late final LoginFormField _senhaForm;
  late final LoginFormField _confirmarSenhaForm;

  @override
  void initState() {
    super.initState();
    _criarCampos();
  }

  void _criarCampos() {
    _nomeForm = LoginFormField(
      hint: AppStrings.digiteSeuNome,
      icon: Phosphor.user,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      validator: validateNome,
    );
    _emailForm = LoginFormField(
      hint: AppStrings.digiteSeuEmail,
      icon: Phosphor.envelope,
      validator: validateEmail,
    );
    _senhaForm = LoginFormField(
      hint: AppStrings.digiteSuaSenha,
      icon: Phosphor.lock,
      obscureText: true,
      textInputAction: TextInputAction.next,
      validator: validateSenhaCadastro,
    );
    _confirmarSenhaForm = LoginFormField(
      hint: AppStrings.confirmeSuaSenha,
      icon: Phosphor.lockSimple,
      obscureText: true,
      validator: (value) => validateConfirmarSenha(value, _senhaForm.value),
    );
  }

  bool _validarFormulario() {
    return validarFormularioComFeedback(_formKey);
  }

  void _salvarCadastro() {
    if (!_validarFormulario()) return;
    bloc.add(
      CadastroUsuarioSaveEvent(
        nome: _nomeForm.value.trim(),
        email: _emailForm.value.trim(),
        senha: _senhaForm.value,
      ),
    );
  }

  Widget _formulario() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          appText(
            'Crie sua conta',
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: AppFontSizes.medium,
          ),
          appSizedBox(height: AppSpacing.small),
          appText(
            'Informe seus dados para começar a controlar seus gastos.',
            color: DinixColors.textMuted,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: AppSpacing.normal),
          _nomeForm.formulario,
          _emailForm.formulario,
          _senhaForm.formulario,
          _confirmarSenhaForm.formulario,
          appSizedBox(height: AppSpacing.medium),
          appElevatedButtonDinix(
            title: AppStrings.cadastrar,
            onTap: _salvarCadastro,
            height: 52,
          ),
        ],
      ),
    );
  }

  Widget _loading() {
    return appLoadingDinix();
  }

  Widget _body() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        physics: const BouncingScrollPhysics(),
        child: _formulario(),
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocBuilder<CadastroUsuarioBloc, CadastroUsuarioState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is CadastroUsuarioLoadingState) {
          return _loading();
        }
        return _body();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kAppSystemUiOverlay,
      child: scaffold(
        title: 'Cadastro',
        centerTitle: true,
        background: DinixColors.background,
        appBarColor: DinixColors.primaryDark,
        titleColor: DinixColors.textPrimary,
        drawerColor: DinixColors.textPrimary,
        body: _bodyBuilder(),
      ),
    );
  }

  @override
  void dispose() {
    _nomeForm.controller.dispose();
    _nomeForm.focusNode.dispose();
    _emailForm.controller.dispose();
    _emailForm.focusNode.dispose();
    _senhaForm.controller.dispose();
    _senhaForm.focusNode.dispose();
    _confirmarSenhaForm.controller.dispose();
    _confirmarSenhaForm.focusNode.dispose();
    bloc.close();
    super.dispose();
  }
}

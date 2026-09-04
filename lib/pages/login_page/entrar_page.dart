import 'package:app_dinix/app_config/app_theme.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/cadastro_fluxo_page.dart';
import 'package:app_dinix/pages/login_page/entrar_bloc.dart';
import 'package:app_dinix/pages/login_page/entrar_event.dart';
import 'package:app_dinix/pages/login_page/entrar_state.dart';
import 'package:app_dinix/pages/login_page/esqueci_senha/esqueci_senha_page.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_logo.dart';
import 'package:app_dinix/widgets/login/login_form_field.dart';
import 'package:app_dinix/widgets/politica_privacidade_aceite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters, appTextButton;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final EntrarBloc bloc = EntrarBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final LoginFormField _loginForm;
  late final LoginFormField _passwordForm;
  bool _aceitouPolitica = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(kAppSystemUiOverlay);
    _criarCampos();
  }

  void _criarCampos() {
    _loginForm = LoginFormField(
      hint: AppStrings.digiteSeuEmail,
      icon: Phosphor.envelope,
      validator: validateEmail,
    );

    _passwordForm = LoginFormField(
      hint: AppStrings.digiteSuaSenha,
      icon: Phosphor.lock,
      obscureText: true,
      validator: validateSenhaLogin,
    );
  }

  bool _validarFormulario() {
    return validarFormularioComFeedback(_formKey);
  }

  void _salvarLogin() {
    if (!_validarFormulario()) return;
    if (!_aceitouPolitica) {
      showToastWarning(
        message: 'Aceite a Política de Privacidade para continuar',
      );
      return;
    }
    bloc.add(EntrarLoginEvent(_loginForm.value.trim(), _passwordForm.value));
  }

  void _abrirCadastro() {
    open(screen: const CadastroFluxoPage());
  }

  void _abrirEsqueciSenha() {
    open(screen: const EsqueciSenhaPage());
  }

  Widget _header() {
    return appLogoDinix(height: 64, showTagline: true);
  }

  Widget _formulario() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          appText(
            'Acesse sua conta',
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: AppFontSizes.medium,
          ),
          appSizedBox(height: AppSpacing.small),
          appText(
            'Entre com e-mail e senha para continuar.',
            color: DinixColors.textMuted,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: AppSpacing.normal),
          _loginForm.formulario,
          _passwordForm.formulario,
          appSizedBox(height: AppSpacing.normal),
          appTextButton(
            text: 'Esqueci minha senha',
            color: DinixColors.primary,
            onTap: _abrirEsqueciSenha,
          ),
          appSizedBox(height: AppSpacing.normal),
          PoliticaPrivacidadeAceite(
            aceito: _aceitouPolitica,
            onChanged: (aceito) => setState(() => _aceitouPolitica = aceito),
          ),
          appSizedBox(height: AppSpacing.medium),
          appElevatedButtonDinix(title: AppStrings.entrar, onTap: _salvarLogin, height: 52),
          appSizedBox(height: AppSpacing.normal),
          appElevatedButtonDinix(
            title: 'Criar conta',
            invertedStyle: true,
            enableEffects: false,
            onTap: _abrirCadastro,
            height: 52,
          ),
        ],
      ),
    );
  }

  Widget _loading() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            appLogoDinix(height: 56),
            appSizedBox(height: AppSpacing.big),
            appLoadingDinix(size: 28),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    return Scaffold(
      backgroundColor: DinixColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(),
                    appSizedBox(height: AppSpacing.medium),
                    Divider(),
                    appSizedBox(height: AppSpacing.medium),
                    _formulario(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocBuilder<EntrarBloc, EntrarState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is EntrarLoadingState) {
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
      child: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    _loginForm.controller.dispose();
    _loginForm.focusNode.dispose();
    _passwordForm.controller.dispose();
    _passwordForm.focusNode.dispose();
    bloc.close();
    super.dispose();
  }
}

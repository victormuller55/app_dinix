import 'package:app_dinix/app_config/app_theme.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/fechar_teclado.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/steps/passo_codigo_conteudo.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/verificacao_email_service.dart';
import 'package:app_dinix/pages/login_page/esqueci_senha/esqueci_senha_service.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/login/login_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

enum _PassoEsqueciSenha { email, codigo, novaSenha }

class EsqueciSenhaPage extends StatefulWidget {
  const EsqueciSenhaPage({super.key});

  @override
  State<EsqueciSenhaPage> createState() => _EsqueciSenhaPageState();
}

class _EsqueciSenhaPageState extends State<EsqueciSenhaPage> {
  _PassoEsqueciSenha _passo = _PassoEsqueciSenha.email;
  bool _carregando = false;
  String _email = '';
  String _codigo = '';

  final GlobalKey<FormState> _formEmail = GlobalKey<FormState>();
  final GlobalKey<FormState> _formSenha = GlobalKey<FormState>();

  late final LoginFormField _emailForm;
  late final LoginFormField _senhaForm;
  late final LoginFormField _confirmarForm;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(kAppSystemUiOverlay);
    _emailForm = LoginFormField(
      hint: AppStrings.digiteSeuEmail,
      icon: Phosphor.envelope,
      validator: validateEmail,
      textInputAction: TextInputAction.done,
    );
    _senhaForm = LoginFormField(
      hint: 'Nova senha',
      icon: Phosphor.lock,
      obscureText: true,
      validator: validateSenhaCadastro,
    );
    _confirmarForm = LoginFormField(
      hint: 'Confirmar nova senha',
      icon: Phosphor.lockSimple,
      obscureText: true,
      textInputAction: TextInputAction.done,
      validator: (value) => validateConfirmarSenha(value, _senhaForm.value),
    );
  }

  String get _titulo => switch (_passo) {
        _PassoEsqueciSenha.email => 'Esqueci minha senha',
        _PassoEsqueciSenha.codigo => 'Código de verificação',
        _PassoEsqueciSenha.novaSenha => 'Nova senha',
      };

  String get _subtitulo => switch (_passo) {
        _PassoEsqueciSenha.email =>
          'Informe o e-mail da sua conta. Enviaremos um código para redefinir a senha.',
        _PassoEsqueciSenha.codigo => 'Digite o código de 6 dígitos enviado para o e-mail.',
        _PassoEsqueciSenha.novaSenha => 'Escolha uma nova senha com no mínimo 8 caracteres.',
      };

  String get _botao => switch (_passo) {
        _PassoEsqueciSenha.email => 'Enviar código',
        _PassoEsqueciSenha.codigo => 'Continuar',
        _PassoEsqueciSenha.novaSenha => 'Redefinir senha',
      };

  void _voltar() {
    if (_passo == _PassoEsqueciSenha.email) {
      Navigator.of(context).maybePop();
      return;
    }
    fecharTeclado();
    setState(() {
      if (_passo == _PassoEsqueciSenha.codigo) {
        _passo = _PassoEsqueciSenha.email;
      } else {
        _passo = _PassoEsqueciSenha.codigo;
      }
    });
  }

  Future<void> _enviarCodigo({bool reenvio = false}) async {
    if (!reenvio && !validarFormularioComFeedback(_formEmail)) return;
    final email = reenvio ? _email : _emailForm.value.trim();
    if (!reenvio) {
      setState(() => _carregando = true);
    }
    try {
      await enviarCodigoEsqueciSenha(email: email);
      if (!mounted) return;
      showToastSuccess(
        message: reenvio
            ? 'Novo código enviado'
            : 'Se o e-mail existir, enviamos um código. Verifique também o spam.',
      );
      setState(() {
        _email = email;
        _passo = _PassoEsqueciSenha.codigo;
        if (reenvio) _codigo = '';
      });
      fecharTeclado();
    } catch (e) {
      showAppErrorFromException(e);
      if (reenvio) rethrow;
    } finally {
      if (mounted && !reenvio) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _continuarCodigo() async {
    if (_codigo.trim().length != 6) {
      showToastError(message: 'Informe o código de 6 dígitos');
      return;
    }
    setState(() => _carregando = true);
    try {
      final ok = await verificarCodigoEmail(email: _email, codigo: _codigo);
      if (!mounted) return;
      if (!ok) {
        showToastError(message: 'Código inválido');
        return;
      }
      setState(() => _passo = _PassoEsqueciSenha.novaSenha);
      fecharTeclado();
    } catch (e) {
      showAppErrorFromException(e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _redefinir() async {
    if (!validarFormularioComFeedback(_formSenha)) return;
    setState(() => _carregando = true);
    try {
      await redefinirSenhaComCodigo(
        email: _email,
        codigo: _codigo,
        senha: _senhaForm.value,
      );
      if (!mounted) return;
      showToastSuccess(message: 'Senha redefinida. Entre com a nova senha.');
      Navigator.of(context).pop(true);
    } catch (e) {
      showAppErrorFromException(e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _continuar() async {
    switch (_passo) {
      case _PassoEsqueciSenha.email:
        await _enviarCodigo();
      case _PassoEsqueciSenha.codigo:
        await _continuarCodigo();
      case _PassoEsqueciSenha.novaSenha:
        await _redefinir();
    }
  }

  Widget _conteudo() {
    return switch (_passo) {
      _PassoEsqueciSenha.email => Form(
          key: _formEmail,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: _emailForm.formulario,
        ),
      _PassoEsqueciSenha.codigo => PassoCodigoConteudo(
          email: _email,
          valorInicial: _codigo,
          onChanged: (value) => _codigo = value,
          onReenviar: () => _enviarCodigo(reenvio: true),
        ),
      _PassoEsqueciSenha.novaSenha => Form(
          key: _formSenha,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              _senhaForm.formulario,
              _confirmarForm.formulario,
            ],
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kAppSystemUiOverlay,
      child: Scaffold(
        backgroundColor: DinixColors.background,
        appBar: AppBar(
          backgroundColor: DinixColors.primaryDark,
          elevation: 0,
          leading: IconButton(
            onPressed: _voltar,
            icon: const Icon(Phosphor.arrowLeft, color: DinixColors.textPrimary),
          ),
          title: appText(
            'Recuperar senha',
            color: DinixColors.textPrimary,
            fontSize: AppFontSizes.small,
            bold: true,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _carregando
              ? appLoadingDinix()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 48,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            appText(
                              _titulo,
                              bold: true,
                              color: DinixColors.textPrimary,
                              fontSize: AppFontSizes.medium,
                              textAlign: TextAlign.center,
                            ),
                            appSizedBox(height: AppSpacing.small),
                            appText(
                              _subtitulo,
                              color: AppColors.grey400,
                              fontSize: AppFontSizes.verySmall,
                              textAlign: TextAlign.center,
                            ),
                            appSizedBox(height: AppSpacing.medium),
                            _conteudo(),
                            appSizedBox(height: AppSpacing.medium),
                            appElevatedButtonDinix(
                              title: _botao,
                              onTap: _continuar,
                              height: 52,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailForm.controller.dispose();
    _emailForm.focusNode.dispose();
    _senhaForm.controller.dispose();
    _senhaForm.focusNode.dispose();
    _confirmarForm.controller.dispose();
    _confirmarForm.focusNode.dispose();
    super.dispose();
  }
}

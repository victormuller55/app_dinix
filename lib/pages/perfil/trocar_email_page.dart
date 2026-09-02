import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/fechar_teclado.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/widgets/codigo_otp_field.dart';
import 'package:app_dinix/pages/perfil/perfil_service.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_form_hint_banner.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/reenviar_codigo_botao.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters, appTextButton;

class TrocarEmailPage extends StatefulWidget {
  final String emailAtual;

  const TrocarEmailPage({super.key, required this.emailAtual});

  @override
  State<TrocarEmailPage> createState() => _TrocarEmailPageState();
}

class _TrocarEmailPageState extends State<TrocarEmailPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AppFormField _emailForm;
  bool _aguardandoCodigo = false;
  bool _carregando = false;
  String _codigo = '';

  @override
  void initState() {
    super.initState();
    _emailForm = criarCampoDinix(
      context: context,
      hint: 'Novo e-mail',
      icon: Phosphor.envelope,
      textInputType: TextInputType.emailAddress,
      validator: (value) {
        final erro = validateEmail(value);
        if (erro != null) return erro;
        if (value!.trim().toLowerCase() == widget.emailAtual.trim().toLowerCase()) {
          return 'Informe um e-mail diferente do atual';
        }
        return null;
      },
    );
  }

  String get _email => _emailForm.value.trim();

  Future<void> _enviarCodigo() async {
    if (!validarFormularioComFeedback(_formKey)) return;
    setState(() => _carregando = true);
    try {
      await enviarCodigoNovoEmail(_email);
      if (!mounted) return;
      showToastSuccess(message: 'Código enviado para $_email');
      fecharTeclado();
      setState(() {
        _aguardandoCodigo = true;
        _codigo = '';
      });
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      showAppErrorFromException(e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _reenviar() async {
    try {
      await enviarCodigoNovoEmail(_email);
      if (!mounted) return;
      showToastSuccess(message: 'Novo código enviado');
    } catch (e) {
      if (await tratarSessaoExpirada(e)) rethrow;
      showAppErrorFromException(e);
      rethrow;
    }
  }

  Future<void> _confirmar() async {
    if (_codigo.length != 6) {
      showToastWarning(message: 'Digite o código de 6 dígitos');
      return;
    }
    setState(() => _carregando = true);
    try {
      await trocarEmailPerfil(email: _email, codigo: _codigo);
      if (!mounted) return;
      showToastSuccess(message: 'E-mail atualizado');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      showAppErrorFromException(e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Widget _passoEmail() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          AppFormHintBanner(
            icon: Phosphor.envelope,
            highlight: 'Atual: ${widget.emailAtual}',
            message:
                'Enviaremos um código para confirmar o novo endereço. Se o e-mail já estiver cadastrado, não será possível usá-lo.',
          ),
          appSizedBox(height: AppSpacing.normal),
          _emailForm.formulario,
          appSizedBox(height: AppSpacing.medium),
          appElevatedButtonDinix(
            title: 'Enviar código',
            onTap: _enviarCodigo,
            height: 52,
          ),
        ],
      ),
    );
  }

  Widget _passoCodigo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                appText(
                  _email,
                  color: DinixColors.primary,
                  fontSize: AppFontSizes.small,
                  textAlign: TextAlign.center,
                ),
                appSizedBox(height: AppSpacing.medium),
                CodigoOtpField(onChanged: (value) => _codigo = value),
                appSizedBox(height: AppSpacing.medium),
                appText(
                  'O código expira em 3 horas. Você pode pedir um novo a cada 5 minutos. Verifique também a caixa de spam.',
                  color: DinixColors.textMuted,
                  fontSize: AppFontSizes.verySmall,
                  textAlign: TextAlign.center,
                ),
                appSizedBox(height: AppSpacing.normal),
                ReenviarCodigoBotao(onReenviar: _reenviar),
                appSizedBox(height: AppSpacing.medium),
                appElevatedButtonDinix(
                  title: 'Confirmar e-mail',
                  onTap: _confirmar,
                  height: 52,
                ),
                appSizedBox(height: AppSpacing.normal),
                appTextButton(
                  text: 'Usar outro e-mail',
                  color: DinixColors.textMuted,
                  onTap: () {
                    fecharTeclado();
                    setState(() => _aguardandoCodigo = false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Trocar e-mail',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      drawerColor: DinixColors.textPrimary,
      body: _carregando
          ? appLoadingDinix()
          : (_aguardandoCodigo ? _passoCodigo() : _passoEmail()),
    );
  }
}

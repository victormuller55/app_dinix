import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/widgets/codigo_otp_field.dart';
import 'package:app_dinix/pages/perfil/perfil_service.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

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
  bool _reenviando = false;
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
    setState(() => _reenviando = true);
    try {
      await enviarCodigoNovoEmail(_email);
      if (!mounted) return;
      showToastSuccess(message: 'Novo código enviado');
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      showAppErrorFromException(e);
    } finally {
      if (mounted) setState(() => _reenviando = false);
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          appText(
            'Atual: ${widget.emailAtual}',
            color: AppColors.grey400,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: AppSpacing.small),
          appText(
            'Enviaremos um código para confirmar o novo endereço.',
            color: AppColors.grey400,
            fontSize: AppFontSizes.verySmall,
          ),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
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
          'O código expira em 3 horas. Verifique também a caixa de spam.',
          color: AppColors.grey400,
          fontSize: AppFontSizes.verySmall,
          textAlign: TextAlign.center,
        ),
        appSizedBox(height: AppSpacing.normal),
        _reenviando
            ? Center(child: appLoadingDinix(size: 22))
            : appTextButton(
                text: 'Reenviar código',
                color: DinixColors.primary,
                onTap: _reenviar,
              ),
        appSizedBox(height: AppSpacing.medium),
        appElevatedButtonDinix(
          title: 'Confirmar e-mail',
          onTap: _confirmar,
          height: 52,
        ),
        appSizedBox(height: AppSpacing.normal),
        appTextButton(
          text: 'Usar outro e-mail',
          color: AppColors.grey400,
          onTap: () => setState(() => _aguardandoCodigo = false),
        ),
      ],
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

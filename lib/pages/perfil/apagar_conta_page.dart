import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/pages/login_page/entrar_page.dart';
import 'package:app_dinix/pages/perfil/perfil_service.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class ApagarContaPage extends StatefulWidget {
  const ApagarContaPage({super.key});

  @override
  State<ApagarContaPage> createState() => _ApagarContaPageState();
}

class _ApagarContaPageState extends State<ApagarContaPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AppFormField _senhaForm;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _senhaForm = criarCampoDinix(
      context: context,
      hint: 'Senha atual',
      icon: Phosphor.lockKey,
      showContent: false,
      validator: validateSenhaLogin,
    );
  }

  Future<void> _apagar() async {
    if (!validarFormularioComFeedback(_formKey)) return;
    final confirmar = await showAppConfirmDialog(
      context,
      title: 'Apagar conta',
      message: 'Isso encerra sua conta e você perderá o acesso aos lançamentos. Essa ação não pode ser desfeita.',
      confirmLabel: 'Apagar conta',
      destructive: true,
      icon: Phosphor.trash,
    );
    if (confirmar != true || !mounted) return;

    setState(() => _carregando = true);
    try {
      await apagarContaPerfil(senha: _senhaForm.value);
      if (!mounted) return;
      showToastSuccess(message: 'Conta encerrada');
      open(screen: const LoginPage(), closePrevious: true);
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      showAppErrorFromException(e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Apagar conta',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      drawerColor: DinixColors.textPrimary,
      body: _carregando
          ? appLoadingDinix()
          : Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Phosphor.warning, color: AppColors.red, size: 22),
                        appSizedBox(width: AppSpacing.normal),
                        Expanded(
                          child: appText(
                            'Sua conta será encerrada. Compras, ganhos e carteiras deixam de ficar acessíveis neste login.',
                            color: DinixColors.textPrimary,
                            fontSize: AppFontSizes.verySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  appSizedBox(height: AppSpacing.medium),
                  appText(
                    'Confirme com a senha atual para continuar.',
                    color: DinixColors.textMuted,
                    fontSize: AppFontSizes.verySmall,
                  ),
                  _senhaForm.formulario,
                  appSizedBox(height: AppSpacing.medium),
                  appElevatedButtonDinix(
                    title: 'Apagar conta',
                    invertedStyle: true,
                    onTap: _apagar,
                    height: 52,
                  ),
                ],
              ),
            ),
    );
  }
}

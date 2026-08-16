import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/pages/perfil/perfil_service.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class TrocarSenhaPage extends StatefulWidget {
  const TrocarSenhaPage({super.key});

  @override
  State<TrocarSenhaPage> createState() => _TrocarSenhaPageState();
}

class _TrocarSenhaPageState extends State<TrocarSenhaPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AppFormField _atualForm;
  late final AppFormField _novaForm;
  late final AppFormField _confirmarForm;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _atualForm = criarCampoDinix(
      context: context,
      hint: 'Senha atual',
      icon: Phosphor.lockKey,
      showContent: false,
      validator: validateSenhaLogin,
    );
    _novaForm = criarCampoDinix(
      context: context,
      hint: 'Nova senha',
      icon: Phosphor.lock,
      showContent: false,
      validator: validateSenhaCadastro,
    );
    _confirmarForm = criarCampoDinix(
      context: context,
      hint: 'Confirmar nova senha',
      icon: Phosphor.lockSimple,
      showContent: false,
      validator: (value) => validateConfirmarSenha(value, _novaForm.value),
    );
  }

  Future<void> _salvar() async {
    if (!validarFormularioComFeedback(_formKey)) return;
    setState(() => _carregando = true);
    try {
      await trocarSenhaPerfil(
        senhaAtual: _atualForm.value,
        senhaNova: _novaForm.value,
      );
      if (!mounted) return;
      showToastSuccess(message: 'Senha atualizada');
      Navigator.of(context).pop(true);
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
      title: 'Trocar senha',
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
                  appText(
                    'Use no mínimo 8 caracteres. Você continua conectado depois de trocar.',
                    color: DinixColors.textMuted,
                    fontSize: AppFontSizes.verySmall,
                  ),
                  _atualForm.formulario,
                  _novaForm.formulario,
                  _confirmarForm.formulario,
                  appSizedBox(height: AppSpacing.medium),
                  appElevatedButtonDinix(
                    title: 'Atualizar senha',
                    onTap: _salvar,
                    height: 52,
                  ),
                ],
              ),
            ),
    );
  }
}

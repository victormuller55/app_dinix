import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/pages/perfil/perfil_service.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_form_hint_banner.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class EditarPerfilPage extends StatefulWidget {
  final String nomeAtual;

  const EditarPerfilPage({super.key, required this.nomeAtual});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AppFormField _nomeForm;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _nomeForm = criarCampoDinix(
      context: context,
      hint: 'Nome completo',
      icon: Phosphor.user,
      textInputType: TextInputType.name,
      validator: validateNome,
    );
    _nomeForm.controller.text = widget.nomeAtual;
  }

  Future<void> _salvar() async {
    if (!validarFormularioComFeedback(_formKey)) return;
    setState(() => _carregando = true);
    try {
      await atualizarNomePerfil(_nomeForm.value);
      if (!mounted) return;
      showToastSuccess(message: 'Perfil atualizado');
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
      title: 'Editar perfil',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.appBar,
      titleColor: DinixColors.onAppBar,
      drawerColor: DinixColors.onAppBar,
      body: _carregando
          ? appLoadingDinix()
          : Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  AppFormHintBanner(
                    icon: Phosphor.user,
                    message:
                        'Esse nome aparece nos seus lançamentos e no perfil.',
                  ),
                  appSizedBox(height: AppSpacing.normal),
                  _nomeForm.formulario,
                  appSizedBox(height: AppSpacing.medium),
                  appElevatedButtonDinix(
                    title: 'Salvar',
                    onTap: _salvar,
                    height: 52,
                  ),
                ],
              ),
            ),
    );
  }
}

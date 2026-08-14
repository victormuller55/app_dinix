import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/local_model.dart';
import 'package:app_dinix/pages/locais/cadastro_local/cadastro_local_bloc.dart';
import 'package:app_dinix/pages/locais/cadastro_local/cadastro_local_event.dart';
import 'package:app_dinix/pages/locais/cadastro_local/cadastro_local_state.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CadastroLocalPage extends StatefulWidget {
  final LocalModel? local;

  const CadastroLocalPage({super.key, this.local});

  @override
  State<CadastroLocalPage> createState() => _CadastroLocalPageState();
}

class _CadastroLocalPageState extends State<CadastroLocalPage> {
  final CadastroLocalBloc bloc = CadastroLocalBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AppFormField _nomeForm;
  late final AppFormField _descricaoForm;
  late final AppFormField _enderecoForm;
  late final AppFormField _cidadeForm;
  late final AppFormField _estadoForm;
  late final bool _isEdit;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.local?.id != null && widget.local!.id!.isNotEmpty;
    _criarCampos();
    _preencher();
  }

  void _criarCampos() {
    _nomeForm = criarCampoDinix(
      context: context,
      hint: 'Nome do estabelecimento',
      icon: Phosphor.storefront,
      validator: (v) => validateObrigatorio(v, campo: 'Nome'),
    );
    _descricaoForm = criarCampoDinix(
      context: context,
      hint: 'Descrição (opcional)',
      icon: Phosphor.note,
    );
    _enderecoForm = criarCampoDinix(
      context: context,
      hint: 'Endereço (opcional)',
      icon: Phosphor.mapPin,
    );
    _cidadeForm = criarCampoDinix(
      context: context,
      hint: 'Cidade (opcional)',
      icon: Phosphor.buildings,
    );
    _estadoForm = criarCampoDinix(
      context: context,
      hint: 'UF (opcional)',
      icon: Phosphor.mapTrifold,
    );
  }

  void _preencher() {
    final local = widget.local;
    if (local == null) return;
    _nomeForm.controller.text = local.nome ?? '';
    _descricaoForm.controller.text = local.descricao ?? '';
    _enderecoForm.controller.text = local.endereco ?? '';
    _cidadeForm.controller.text = local.cidade ?? '';
    _estadoForm.controller.text = local.estado ?? '';
  }

  String? _opcional(String value) {
    final t = value.trim();
    return t.isEmpty ? null : t;
  }

  void _salvarCadastro() {
    if (!validarFormularioComFeedback(_formKey)) return;
    bloc.add(
      CadastroLocalSaveEvent(
        local: LocalModel(
          id: widget.local?.id,
          nome: _nomeForm.value.trim(),
          descricao: _opcional(_descricaoForm.value),
          endereco: _opcional(_enderecoForm.value),
          cidade: _opcional(_cidadeForm.value),
          estado: _opcional(_estadoForm.value),
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao() async {
    final id = widget.local?.id;
    if (id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Remover estabelecimento',
      message: 'Este local será removido. Deseja continuar?',
      confirmLabel: 'Remover',
      destructive: true,
    );
    if (ok == true) bloc.add(CadastroLocalDeleteEvent(id: id));
  }

  void _onState(CadastroLocalState state) {
    if (state is CadastroLocalSuccessState) {
      showToastSuccess(message: _isEdit ? 'Estabelecimento atualizado' : 'Estabelecimento cadastrado');
      Navigator.of(context).pop(true);
    }
    if (state is CadastroLocalDeletedState) {
      showToastSuccess(message: 'Estabelecimento removido');
      Navigator.of(context).pop(true);
    }
    if (state is CadastroLocalErrorState) {
      showAppErrorSnackbar(state.errorModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: _isEdit ? 'Editar local' : 'Novo estabelecimento',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      drawerColor: DinixColors.textPrimary,
      body: BlocConsumer<CadastroLocalBloc, CadastroLocalState>(
        bloc: bloc,
        listener: (_, state) => _onState(state),
        builder: (context, state) {
          if (state is CadastroLocalLoadingState) return appLoadingDinix();
          return Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _nomeForm.formulario,
                _descricaoForm.formulario,
                _enderecoForm.formulario,
                _cidadeForm.formulario,
                _estadoForm.formulario,
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
        },
      ),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}

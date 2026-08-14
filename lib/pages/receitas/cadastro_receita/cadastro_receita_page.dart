import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/receita_model.dart';
import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_bloc.dart';
import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_event.dart';
import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_state.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_select_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CadastroReceitaPage extends StatefulWidget {
  final ReceitaModel? receita;

  const CadastroReceitaPage({super.key, this.receita});

  @override
  State<CadastroReceitaPage> createState() => _CadastroReceitaPageState();
}

class _CadastroReceitaPageState extends State<CadastroReceitaPage> {
  final CadastroReceitaBloc bloc = CadastroReceitaBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AppFormField _valorForm;
  late final AppFormField _origemForm;
  late final AppFormField _contaForm;
  late final AppFormField _dataForm;
  late final AppFormField _descricaoForm;
  late final AppFormField _obsForm;
  late final bool _isEdit;

  CadastroReceitaLookups? _lookups;
  String? _idCategoria;
  String? _idConta;
  bool _recorrente = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.receita?.id != null && widget.receita!.id!.isNotEmpty;
    _idCategoria = widget.receita?.idCategoria;
    _idConta = widget.receita?.idConta;
    _recorrente = widget.receita?.recorrente ?? false;
    _criarCampos();
    _preencher();
    bloc.add(CadastroReceitaLoadEvent());
  }

  void _criarCampos() {
    _valorForm = criarCampoDinix(
      context: context,
      hint: 'Valor recebido',
      icon: Phosphor.money,
      textInputType: TextInputType.number,
      textInputFormatter: AppFormFormatters.valor,
      validator: validateValor,
    );
    _origemForm = criarCampoDinix(
      context: context,
      hint: 'Como ganhou',
      icon: Phosphor.tag,
      showKeyboard: false,
      onTap: _escolherOrigem,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
      validator: (v) => validateObrigatorio(v, campo: 'Origem do ganho'),
    );
    _contaForm = criarCampoDinix(
      context: context,
      hint: 'Conta de destino',
      icon: Phosphor.wallet,
      showKeyboard: false,
      onTap: _escolherConta,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
      validator: (v) => validateObrigatorio(v, campo: 'Conta'),
    );
    _dataForm = criarCampoDinix(
      context: context,
      hint: 'Data do recebimento',
      icon: Phosphor.calendarBlank,
      textInputType: TextInputType.number,
      textInputFormatter: AppFormFormatters.data,
      validator: validateDataBr,
    );
    _descricaoForm = criarCampoDinix(
      context: context,
      hint: 'Descrição (opcional)',
      icon: Phosphor.fileText,
    );
    _obsForm = criarCampoDinix(
      context: context,
      hint: 'Observações (opcional)',
      icon: Phosphor.note,
      maxLines: 3,
    );
  }

  void _preencher() {
    final receita = widget.receita;
    _dataForm.controller.text = isoParaBr(receita?.dataRecebimento ?? dataHojeIso());
    if (receita == null) return;
    if (receita.valor != null) {
      _valorForm.controller.text = formataMoedaCampo(receita.valor);
    }
    _descricaoForm.controller.text = receita.descricao ?? '';
    _obsForm.controller.text = receita.observacoes ?? '';
  }

  void _aplicarLookups(CadastroReceitaLookups lookups) {
    _lookups = lookups;
    final origem = lookups.origens.where((c) => c.id == _idCategoria).firstOrNull;
    if (origem != null) _origemForm.controller.text = origem.nome ?? '';
    final conta = lookups.contas.where((c) => c.id == _idConta).firstOrNull;
    if (conta != null) {
      _contaForm.controller.text = conta.nomeBanco ?? conta.nome ?? '';
    }
  }

  Future<void> _escolherOrigem() async {
    final items = _lookups?.origens ?? [];
    if (items.isEmpty) {
      showToastWarning(message: 'Nenhuma origem de ganho disponível.');
      return;
    }
    final selecionada = await showAppSelectSheet<CategoriaModel>(
      context: context,
      title: 'Como ganhou',
      items: items,
      labelOf: (c) => c.nome ?? '',
      selected: items.where((c) => c.id == _idCategoria).firstOrNull,
    );
    if (selecionada == null) return;
    setState(() {
      _idCategoria = selecionada.id;
      _origemForm.controller.text = selecionada.nome ?? '';
    });
  }

  Future<void> _escolherConta() async {
    final items = _lookups?.contas ?? [];
    if (items.isEmpty) {
      showToastWarning(message: 'Cadastre uma conta em Carteiras antes.');
      return;
    }
    final selecionada = await showAppSelectSheet<ContaModel>(
      context: context,
      title: 'Conta de destino',
      items: items,
      labelOf: (c) => c.nomeBanco ?? c.nome ?? '',
      selected: items.where((c) => c.id == _idConta).firstOrNull,
    );
    if (selecionada == null) return;
    setState(() {
      _idConta = selecionada.id;
      _contaForm.controller.text = selecionada.nomeBanco ?? selecionada.nome ?? '';
    });
  }

  void _salvarCadastro() {
    if (!validarFormularioComFeedback(_formKey)) return;
    if (_idConta == null || _idConta!.isEmpty) {
      showToastWarning(message: 'Selecione a conta de destino.');
      return;
    }
    if (_idCategoria == null || _idCategoria!.isEmpty) {
      showToastWarning(message: 'Selecione como ganhou esse valor.');
      return;
    }

    final origem = _lookups?.origens.where((c) => c.id == _idCategoria).firstOrNull;
    final descricao = _descricaoForm.value.trim().isNotEmpty
        ? _descricaoForm.value.trim()
        : (origem?.nome ?? 'Ganho');

    bloc.add(
      CadastroReceitaSaveEvent(
        receita: ReceitaModel(
          id: widget.receita?.id,
          descricao: descricao,
          valor: parseValor(_valorForm.value),
          idCategoria: _idCategoria,
          idConta: _idConta,
          dataRecebimento: brParaIso(_dataForm.value),
          recorrente: _recorrente,
          observacoes: _obsForm.value.trim().isEmpty ? null : _obsForm.value.trim(),
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao() async {
    final id = widget.receita?.id;
    if (id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Excluir ganho',
      message: 'O ganho será removido e o saldo da conta será ajustado. Deseja continuar?',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (ok == true) bloc.add(CadastroReceitaDeleteEvent(id: id));
  }

  void _onState(CadastroReceitaState state) {
    if (state is CadastroReceitaReadyState) _aplicarLookups(state.lookups);
    if (state is CadastroReceitaSuccessState) {
      showToastSuccess(message: _isEdit ? 'Ganho atualizado' : 'Ganho cadastrado');
      Navigator.of(context).pop(true);
    }
    if (state is CadastroReceitaDeletedState) {
      showToastSuccess(message: 'Ganho excluído');
      Navigator.of(context).pop(true);
    }
    if (state is CadastroReceitaErrorState) {
      showAppErrorSnackbar(state.errorModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: _isEdit ? 'Editar ganho' : 'Novo ganho',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      drawerColor: DinixColors.textPrimary,
      body: BlocConsumer<CadastroReceitaBloc, CadastroReceitaState>(
        bloc: bloc,
        listener: (_, state) => _onState(state),
        builder: (context, state) {
          if (state is CadastroReceitaLoadingState || state is CadastroReceitaInitialState) {
            return appLoadingDinix();
          }
          return Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _valorForm.formulario,
                _origemForm.formulario,
                _contaForm.formulario,
                _dataForm.formulario,
                _descricaoForm.formulario,
                SwitchListTile(
                  value: _recorrente,
                  activeThumbColor: DinixColors.primary,
                  title: appText('Recebimento recorrente', color: DinixColors.textPrimary),
                  subtitle: appText(
                    'Aparece na previsão mensal',
                    color: AppColors.grey400,
                    fontSize: AppFontSizes.verySmall,
                  ),
                  onChanged: (v) => setState(() => _recorrente = v),
                ),
                _obsForm.formulario,
                appSizedBox(height: AppSpacing.medium),
                appElevatedButtonDinix(
                  title: _isEdit ? AppStrings.salvar : 'Cadastrar',
                  onTap: _salvarCadastro,
                  height: 52,
                ),
                if (_isEdit) ...[
                  appSizedBox(height: AppSpacing.normal),
                  appElevatedButtonDinix(
                    title: 'Excluir ganho',
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

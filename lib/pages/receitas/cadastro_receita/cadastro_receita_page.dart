import 'package:app_dinix/app_config/apple_intelligence_bridge.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/categoria_icone.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/receita_model.dart';
import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_bloc.dart';
import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_event.dart';
import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_state.dart';
import 'package:app_dinix/widgets/app_cadastro_style.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_select_sheet.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:app_dinix/widgets/categoria_select_sheet.dart';
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
  final TextEditingController _valorController = TextEditingController();
  final FocusNode _valorFocus = FocusNode();

  late final AppFormField _descricaoForm;
  late final AppFormField _obsForm;
  late final bool _isEdit;

  CadastroReceitaLookups? _lookups;
  String? _idCategoria;
  String? _idConta;
  late DateTime _dataRecebimento;
  bool _recorrente = false;
  /// Marcado = credita na conta agora. Desmarcado = agenda para o próximo mês.
  bool _creditarAgora = true;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.receita?.id != null && widget.receita!.id!.isNotEmpty;
    _idCategoria = widget.receita?.idCategoria;
    _idConta = widget.receita?.idConta;
    _recorrente = widget.receita?.recorrente ?? false;
    _dataRecebimento = _parseDataInicial(widget.receita?.dataRecebimento);
    _criarCampos();
    _preencher();
    _valorFocus.addListener(_aoFocarValor);
    bloc.add(CadastroReceitaLoadEvent());
    final id = widget.receita?.id;
    if (id != null && id.isNotEmpty) {
      setAppleIntelligenceOnScreenEntity(
        type: AppleIntelligenceEntityType.receita,
        id: id,
        title: widget.receita?.descricao,
      );
    }
  }

  void _aoFocarValor() {
    if (_valorFocus.hasFocus) return;
    normalizarValorCampo(_valorController);
  }

  DateTime _parseDataInicial(String? iso) {
    final parsed = iso != null && iso.length >= 10
        ? DateTime.tryParse(iso.substring(0, 10))
        : null;
    if (parsed != null) return DateTime(parsed.year, parsed.month, parsed.day);
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day);
  }

  void _criarCampos() {
    _descricaoForm = criarCampoDinix(
      context: context,
      hint: 'O que foi recebido',
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
    if (receita?.valor != null) {
      _valorController.text = formataMoedaCampo(receita!.valor);
    } else if (!_isEdit) {
      _valorController.text = formataMoedaCampo(kCadastroValorPadrao);
    }
    if (receita == null) return;
    _descricaoForm.controller.text = receita.descricao ?? '';
    _obsForm.controller.text = receita.observacoes ?? '';
  }

  Future<void> _escolherOrigem() async {
    final items = _lookups?.origens ?? [];
    if (items.isEmpty) {
      showToastWarning(message: 'Nenhuma origem de ganho disponível.');
      return;
    }
    final selecionada = await showCategoriaSelectSheet(
      context: context,
      title: 'Como ganhou',
      categorias: items,
      selected: items.where((c) => c.id == _idCategoria).firstOrNull,
    );
    if (selecionada == null) return;
    setState(() => _idCategoria = selecionada.id);
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
      labelOf: (c) => c.nome ?? 'Conta',
      subtitleOf: (c) => c.nomeBanco,
      selected: items.where((c) => c.id == _idConta).firstOrNull,
      leadingOf: (c) => bancoIcon(banco: c.nomeBanco ?? c.nome, size: 32),
    );
    if (selecionada == null) return;
    setState(() => _idConta = selecionada.id);
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

    final origem =
        _lookups?.origens.where((c) => c.id == _idCategoria).firstOrNull;
    final descricao = _descricaoForm.value.trim().isNotEmpty
        ? _descricaoForm.value.trim()
        : (origem?.nome ?? 'Ganho');

    final valor = (parseValor(_valorController.text) ?? kCadastroValorPadrao)
        .clamp(kCadastroValorMinimo, kCadastroValorMaximo)
        .toDouble();

    bloc.add(
      CadastroReceitaSaveEvent(
        receita: ReceitaModel(
          id: widget.receita?.id,
          descricao: descricao,
          valor: valor,
          idCategoria: _idCategoria,
          idConta: _idConta,
          dataRecebimento: dateTimeParaIso(_dataRecebimento),
          recorrente: _recorrente,
          observacoes:
              _obsForm.value.trim().isEmpty ? null : _obsForm.value.trim(),
        ),
        creditarAgora: _isEdit || _creditarAgora,
      ),
    );
  }

  Future<void> _confirmarExclusao() async {
    final id = widget.receita?.id;
    if (id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Excluir ganho',
      message:
          'O ganho será removido e o saldo da conta será ajustado. Deseja continuar?',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (ok == true) bloc.add(CadastroReceitaDeleteEvent(id: id));
  }

  void _onState(CadastroReceitaState state) {
    if (state is CadastroReceitaReadyState) {
      setState(() => _lookups = state.lookups);
    }
    if (state is CadastroReceitaSuccessState) {
      showToastSuccess(
        message: _isEdit
            ? 'Ganho atualizado'
            : state.creditarAgora
                ? 'Ganho cadastrado'
                : 'Ganho agendado para o próximo mês',
      );
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
    final origem =
        _lookups?.origens.where((c) => c.id == _idCategoria).firstOrNull;
    final conta = _lookups?.contas.where((c) => c.id == _idConta).firstOrNull;

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
          if (state is CadastroReceitaLoadingState ||
              state is CadastroReceitaInitialState) {
            return appLoadingDinix();
          }
          return Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                cadastroCampoValor(
                  titulo: 'Valor',
                  controller: _valorController,
                  focusNode: _valorFocus,
                  validator: validateValor,
                  onChanged: () => setState(() {}),
                ),
                cadastroSecao(
                  'O que foi recebido',
                  _descricaoForm.formulario,
                ),
                cadastroCampoQuando(
                  data: _dataRecebimento,
                  onChanged: (d) => setState(() => _dataRecebimento = d),
                ),
                cadastroSecao(
                  'Como ganhou',
                  cadastroBotaoSeletor(
                    tituloVazio: 'Selecionar origem',
                    valor: origem?.nome,
                    leading: Icon(
                      iconeDaCategoria(origem),
                      color: DinixColors.primary,
                    ),
                    onTap: _escolherOrigem,
                  ),
                ),
                cadastroSecao(
                  'Conta de destino',
                  cadastroBotaoSeletor(
                    tituloVazio: 'Selecionar conta',
                    valor: conta?.nome,
                    leading: conta == null
                        ? Icon(Phosphor.wallet, color: DinixColors.primary)
                        : bancoIcon(
                            banco: conta.nomeBanco ?? conta.nome,
                            size: 28,
                          ),
                    onTap: _escolherConta,
                  ),
                ),
                if (!_isEdit)
                  cadastroSwitch(
                    titulo: 'Adicionar ao saldo agora',
                    subtitulo: _creditarAgora
                        ? 'O valor entra na conta imediatamente'
                        : 'Salva para o próximo mês e aparece no dia 1 para confirmar',
                    value: _creditarAgora,
                    onChanged: (v) => setState(() => _creditarAgora = v),
                  ),
                if (!_isEdit || _creditarAgora)
                  cadastroSwitch(
                    titulo: 'Recebimento recorrente',
                    subtitulo: _creditarAgora
                        ? 'Aparece na previsão mensal'
                        : 'Mantém nos meses seguintes após o primeiro',
                    value: _recorrente,
                    onChanged: (v) => setState(() => _recorrente = v),
                  ),
                cadastroSecao('Observações', _obsForm.formulario),
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
    clearAppleIntelligenceOnScreenEntity();
    _valorFocus.removeListener(_aoFocarValor);
    _valorController.dispose();
    _valorFocus.dispose();
    bloc.close();
    super.dispose();
  }
}

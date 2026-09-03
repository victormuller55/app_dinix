import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/bancos_catalogo.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/pages/carteiras/cadastro_conta/cadastro_conta_bloc.dart';
import 'package:app_dinix/pages/carteiras/cadastro_conta/cadastro_conta_event.dart';
import 'package:app_dinix/pages/carteiras/cadastro_conta/cadastro_conta_state.dart';
import 'package:app_dinix/widgets/app_cadastro_style.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:app_dinix/widgets/banco_select_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CadastroContaPage extends StatefulWidget {
  final ContaModel? conta;

  const CadastroContaPage({super.key, this.conta});

  @override
  State<CadastroContaPage> createState() => _CadastroContaPageState();
}

class _CadastroContaPageState extends State<CadastroContaPage> {
  final CadastroContaBloc bloc = CadastroContaBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _saldoController = TextEditingController();
  final FocusNode _saldoFocus = FocusNode();

  late final bool _isEdit;
  String _tipoConta = TipoConta.contaCorrente;
  BancoOpcao? _banco;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.conta?.id != null && widget.conta!.id!.isNotEmpty;
    _tipoConta = widget.conta?.tipoConta ?? TipoConta.contaCorrente;
    _banco = _resolverBanco(widget.conta?.nomeBanco);
    _preencher();
    _saldoFocus.addListener(_aoFocarSaldo);
  }

  BancoOpcao? _resolverBanco(String? nome) {
    final catalogo = BancosCatalogo.porNome(nome);
    if (catalogo != null) return catalogo;
    if (nome == null || nome.trim().isEmpty) return null;
    return BancoOpcao(
      nome: nome.trim(),
      cor: widget.conta?.cor ?? '#FF9800',
    );
  }

  void _aoFocarSaldo() {
    if (_saldoFocus.hasFocus) return;
    normalizarValorCampo(
      _saldoController,
      min: 0,
      fallback: 0,
    );
  }

  void _preencher() {
    final conta = widget.conta;
    if (conta == null) {
      _saldoController.text = formataMoedaCampo(0);
      return;
    }
    final saldo = conta.saldoAtual ?? conta.saldoInicial;
    _saldoController.text = formataMoedaCampo(saldo ?? 0);
  }

  Future<void> _escolherBanco() async {
    final selecionado = await showBancoSelectSheet(
      context: context,
      selected: _banco,
    );
    if (selecionado == null) return;
    setState(() => _banco = selecionado);
  }

  void _salvarCadastro() {
    if (_banco == null) {
      showToastWarning(message: 'Selecione o banco');
      return;
    }
    if (!validarFormularioComFeedback(_formKey)) return;
    final saldo = parseValor(_saldoController.text) ?? 0;
    bloc.add(
      CadastroContaSaveEvent(
        conta: ContaModel(
          id: widget.conta?.id,
          nome: _banco!.nome,
          nomeBanco: _banco!.nome,
          tipoConta: _tipoConta,
          saldoAtual: saldo,
          cor: _banco!.cor,
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao() async {
    final id = widget.conta?.id;
    if (id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Remover conta',
      message: 'Esta conta será removida. Deseja continuar?',
      confirmLabel: 'Remover',
      destructive: true,
    );
    if (ok == true) {
      bloc.add(CadastroContaDeleteEvent(id: id));
    }
  }

  void _onState(CadastroContaState state) {
    if (state is CadastroContaSuccessState) {
      showToastSuccess(
        message: _isEdit ? 'Conta atualizada' : 'Conta cadastrada',
      );
      Navigator.of(context).pop(true);
    }
    if (state is CadastroContaDeletedState) {
      showToastSuccess(message: 'Conta removida');
      Navigator.of(context).pop(true);
    }
    if (state is CadastroContaErrorState) {
      showAppErrorSnackbar(state.errorModel);
    }
  }

  Widget _formulario() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          cadastroSecao(
            'Banco',
            cadastroBotaoSeletor(
              tituloVazio: 'Selecionar banco',
              valor: _banco?.nome,
              leading: _banco == null
                  ? Icon(Phosphor.bank, color: DinixColors.primary)
                  : bancoIcon(
                      banco: _banco!.nome,
                      size: 28,
                      gradient: _banco!.gradiente,
                    ),
              onTap: _escolherBanco,
            ),
          ),
          cadastroSecao(
            'Tipo de conta',
            cadastroGradeChips(
              [
                for (final tipo in TipoConta.valores)
                  cadastroChip(
                    label: TipoConta.rotulo(tipo),
                    selecionado: _tipoConta == tipo,
                    onTap: () => setState(() => _tipoConta = tipo),
                  ),
              ],
              colunas: 2,
            ),
          ),
          cadastroCampoValor(
            titulo: 'Saldo atual',
            controller: _saldoController,
            focusNode: _saldoFocus,
            min: 0,
            padrao: 0,
            validator: validateValorOpcional,
            onChanged: () => setState(() {}),
          ),
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
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: _isEdit ? 'Editar conta' : 'Nova conta',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.appBar,
      titleColor: DinixColors.onAppBar,
      drawerColor: DinixColors.onAppBar,
      body: BlocConsumer<CadastroContaBloc, CadastroContaState>(
        bloc: bloc,
        listener: (_, state) => _onState(state),
        builder: (context, state) {
          if (state is CadastroContaLoadingState) return appLoadingDinix();
          return _formulario();
        },
      ),
    );
  }

  @override
  void dispose() {
    _saldoFocus.removeListener(_aoFocarSaldo);
    _saldoController.dispose();
    _saldoFocus.dispose();
    bloc.close();
    super.dispose();
  }
}

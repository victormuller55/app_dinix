import 'package:app_dinix/app_config/bancos_catalogo.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cadastro_cartao/cadastro_cartao_bloc.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cadastro_cartao/cadastro_cartao_event.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cadastro_cartao/cadastro_cartao_state.dart';
import 'package:app_dinix/pages/carteiras/cartoes/detalhe_cartao/detalhe_cartao_page.dart';
import 'package:app_dinix/widgets/app_cadastro_style.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_select_sheet.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:app_dinix/widgets/banco_select_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CadastroCartaoPage extends StatefulWidget {
  final CartaoCreditoModel? cartao;

  const CadastroCartaoPage({super.key, this.cartao});

  @override
  State<CadastroCartaoPage> createState() => _CadastroCartaoPageState();
}

class _CadastroCartaoPageState extends State<CadastroCartaoPage> {
  final CadastroCartaoBloc bloc = CadastroCartaoBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _limiteController = TextEditingController();
  final FocusNode _limiteFocus = FocusNode();

  late final AppFormField _nomeForm;
  late final bool _isEdit;

  List<ContaModel> _contas = [];
  String? _idConta;
  BancoOpcao? _banco;
  int _diaFechamento = 1;
  int _diaVencimento = 10;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.cartao?.id != null && widget.cartao!.id!.isNotEmpty;
    _idConta = widget.cartao?.idConta;
    _banco = _resolverBanco(widget.cartao?.banco);
    _diaFechamento = widget.cartao?.diaFechamento ?? 1;
    _diaVencimento = widget.cartao?.diaVencimento ?? 10;
    if (_diaFechamento < 1) _diaFechamento = 1;
    if (_diaFechamento > 31) _diaFechamento = 31;
    if (_diaVencimento < 1) _diaVencimento = 1;
    if (_diaVencimento > 31) _diaVencimento = 31;
    _criarCampos();
    _preencher();
    _limiteFocus.addListener(_aoFocarLimite);
    bloc.add(CadastroCartaoLoadEvent());
  }

  BancoOpcao? _resolverBanco(String? nome) {
    final catalogo = BancosCatalogo.porNome(nome);
    if (catalogo != null) return catalogo;
    if (nome == null || nome.trim().isEmpty) return null;
    return BancoOpcao(nome: nome.trim(), cor: '#FF9800');
  }

  void _aoFocarLimite() {
    if (_limiteFocus.hasFocus) return;
    normalizarValorCampo(_limiteController);
  }

  void _criarCampos() {
    _nomeForm = criarCampoDinix(
      context: context,
      hint: 'Nome do cartão',
      icon: Phosphor.creditCard,
      validator: (v) => validateObrigatorio(v, campo: 'Nome'),
    );
  }

  void _preencher() {
    final cartao = widget.cartao;
    if (cartao?.limite != null) {
      _limiteController.text = formataMoedaCampo(cartao!.limite);
    } else if (!_isEdit) {
      _limiteController.text = formataMoedaCampo(kCadastroValorPadrao);
    }
    if (cartao == null) return;
    _nomeForm.controller.text = cartao.nome ?? '';
  }

  Future<void> _escolherBanco() async {
    final selecionado = await showBancoSelectSheet(
      context: context,
      selected: _banco,
    );
    if (selecionado == null) return;
    setState(() => _banco = selecionado);
  }

  Future<void> _escolherConta() async {
    if (_contas.isEmpty) {
      showToastWarning(message: 'Cadastre uma conta antes de criar o cartão.');
      return;
    }
    final selecionada = await showAppSelectSheet<ContaModel>(
      context: context,
      title: 'Conta de pagamento',
      items: _contas,
      labelOf: (c) => c.nome ?? '',
      subtitleOf: (c) => c.nomeBanco,
      selected: _contas.where((c) => c.id == _idConta).firstOrNull,
      leadingOf: (c) => bancoIcon(banco: c.nomeBanco ?? c.nome, size: 32),
    );
    if (selecionada == null) return;
    setState(() => _idConta = selecionada.id);
  }

  void _salvarCadastro() {
    if (!validarFormularioComFeedback(_formKey)) return;
    if (_banco == null) {
      showToastWarning(message: 'Selecione o banco');
      return;
    }
    if (_idConta == null || _idConta!.isEmpty) {
      showToastWarning(message: 'Selecione a conta de pagamento da fatura.');
      return;
    }

    final limite = (parseValor(_limiteController.text) ?? kCadastroValorPadrao)
        .clamp(kCadastroValorMinimo, kCadastroValorMaximo)
        .toDouble();

    bloc.add(
      CadastroCartaoSaveEvent(
        cartao: CartaoCreditoModel(
          id: widget.cartao?.id,
          idConta: _idConta,
          nome: _nomeForm.value.trim(),
          banco: _banco!.nome,
          limite: limite,
          diaFechamento: _diaFechamento,
          diaVencimento: _diaVencimento,
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao() async {
    final id = widget.cartao?.id;
    if (id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Remover cartão',
      message: 'Este cartão será removido. Deseja continuar?',
      confirmLabel: 'Remover',
      destructive: true,
    );
    if (ok == true) bloc.add(CadastroCartaoDeleteEvent(id: id));
  }

  void _onState(CadastroCartaoState state) {
    if (state is CadastroCartaoReadyState) {
      setState(() => _contas = state.contas);
    }
    if (state is CadastroCartaoSuccessState) {
      showToastSuccess(
        message: _isEdit ? 'Cartão atualizado' : 'Cartão cadastrado',
      );
      if (_isEdit) {
        Navigator.of(context).pop(true);
        return;
      }
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (_) => DetalheCartaoPage(cartao: state.cartao),
        ),
      );
    }
    if (state is CadastroCartaoDeletedState) {
      showToastSuccess(message: 'Cartão removido');
      Navigator.of(context).pop(true);
    }
    if (state is CadastroCartaoErrorState) {
      showAppErrorSnackbar(state.errorModel);
    }
  }

  Widget _formulario() {
    final conta = _contas.where((c) => c.id == _idConta).firstOrNull;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          cadastroCampoValor(
            titulo: 'Limite',
            controller: _limiteController,
            focusNode: _limiteFocus,
            validator: validateValor,
            onChanged: () => setState(() {}),
          ),
          cadastroSecao('Nome', _nomeForm.formulario),
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
            'Conta de pagamento',
            cadastroBotaoSeletor(
              tituloVazio: 'Selecionar conta',
              valor: conta?.nome,
              leading: conta == null
                  ? Icon(Phosphor.wallet, color: DinixColors.primary)
                  : bancoIcon(banco: conta.nomeBanco ?? conta.nome, size: 28),
              onTap: _escolherConta,
            ),
          ),
          cadastroCampoInteiro(
            titulo: 'Dia de fechamento',
            valor: _diaFechamento,
            min: 1,
            max: 31,
            onChanged: (v) => setState(() => _diaFechamento = v),
            rotulo: (v) => 'Dia $v',
          ),
          cadastroCampoInteiro(
            titulo: 'Dia de vencimento',
            valor: _diaVencimento,
            min: 1,
            max: 31,
            onChanged: (v) => setState(() => _diaVencimento = v),
            rotulo: (v) => 'Dia $v',
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
      title: _isEdit ? 'Editar cartão' : 'Novo cartão',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      drawerColor: DinixColors.textPrimary,
      body: BlocConsumer<CadastroCartaoBloc, CadastroCartaoState>(
        bloc: bloc,
        listener: (_, state) => _onState(state),
        builder: (context, state) {
          if (state is CadastroCartaoLoadingState ||
              state is CadastroCartaoInitialState) {
            return appLoadingDinix();
          }
          if (state is CadastroCartaoErrorState && _contas.isEmpty) {
            return Center(
              child: appElevatedButtonDinix(
                title: 'Tentar novamente',
                onTap: () => bloc.add(CadastroCartaoLoadEvent()),
              ),
            );
          }
          return _formulario();
        },
      ),
    );
  }

  @override
  void dispose() {
    _limiteFocus.removeListener(_aoFocarLimite);
    _limiteController.dispose();
    _limiteFocus.dispose();
    bloc.close();
    super.dispose();
  }
}

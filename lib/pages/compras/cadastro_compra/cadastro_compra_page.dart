import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/categoria_icone.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/compra_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/local_model.dart';
import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_bloc.dart';
import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_event.dart';
import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_state.dart';
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

class CadastroCompraPage extends StatefulWidget {
  final CompraModel? compra;

  const CadastroCompraPage({super.key, this.compra});

  @override
  State<CadastroCompraPage> createState() => _CadastroCompraPageState();
}

class _CadastroCompraPageState extends State<CadastroCompraPage> {
  final CadastroCompraBloc bloc = CadastroCompraBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();
  final FocusNode _valorFocus = FocusNode();

  late final AppFormField _descricaoForm;
  late final AppFormField _obsForm;
  late final bool _isEdit;

  CadastroCompraLookups? _lookups;
  late DateTime _dataCompra;
  String? _idCategoria;
  String? _idLocal;
  String _formaPagamento = FormaPagamento.pix;
  String? _idConta;
  String? _idCartao;
  int _parcelas = 1;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.compra?.id != null && widget.compra!.id!.isNotEmpty;
    _idCategoria = widget.compra?.idCategoria;
    _idLocal = widget.compra?.idLocal;
    _formaPagamento = widget.compra?.formaPagamento ?? FormaPagamento.pix;
    _idConta = widget.compra?.idConta;
    _idCartao = widget.compra?.idCartaoCredito;
    _parcelas = widget.compra?.qtdParcelas ?? 1;
    _dataCompra = _parseDataInicial(widget.compra?.dataCompra);
    _criarCampos();
    _preencher();
    _valorFocus.addListener(_aoFocarValor);
    bloc.add(CadastroCompraLoadEvent());
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
      hint: 'O que foi comprado',
      icon: Phosphor.shoppingBag,
      validator: (v) => validateObrigatorio(v, campo: 'Descrição'),
    );
    _obsForm = criarCampoDinix(
      context: context,
      hint: 'Observações (opcional)',
      icon: Phosphor.note,
      maxLines: 3,
    );
  }

  void _preencher() {
    final compra = widget.compra;
    if (compra?.valorTotal != null) {
      _valorController.text = formataMoedaCampo(compra!.valorTotal);
    } else if (!_isEdit) {
      _valorController.text = formataMoedaCampo(kCadastroValorPadrao);
    }
    if (compra == null) return;
    _descricaoForm.controller.text = compra.descricao ?? '';
    _obsForm.controller.text = compra.observacoes ?? '';
  }

  void _selecionarPagamento(String forma) {
    if (_isEdit) return;
    setState(() {
      _formaPagamento = forma;
      if (FormaPagamento.usaCartao(forma)) {
        _idConta = null;
      } else {
        _idCartao = null;
        _parcelas = 1;
      }
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
      title: 'Conta',
      items: items,
      labelOf: (c) => c.nome ?? 'Conta',
      subtitleOf: (c) => c.nomeBanco,
      selected: items.where((c) => c.id == _idConta).firstOrNull,
      leadingOf: (c) => bancoIcon(banco: c.nomeBanco ?? c.nome, size: 32),
    );
    if (selecionada == null) return;
    setState(() => _idConta = selecionada.id);
  }

  Future<void> _escolherCartao() async {
    final items = _lookups?.cartoes ?? [];
    if (items.isEmpty) {
      showToastWarning(message: 'Cadastre um cartão em Carteiras antes.');
      return;
    }
    final selecionado = await showAppSelectSheet<CartaoCreditoModel>(
      context: context,
      title: 'Cartão',
      items: items,
      labelOf: (c) => c.nome ?? 'Cartão',
      subtitleOf: (c) => c.banco,
      selected: items.where((c) => c.id == _idCartao).firstOrNull,
      leadingOf: (c) => bancoIcon(banco: c.banco ?? c.nome, size: 32),
    );
    if (selecionado == null) return;
    setState(() => _idCartao = selecionado.id);
  }

  Future<void> _escolherCategoria() async {
    final items = _lookups?.categorias ?? [];
    if (items.isEmpty) {
      showToastWarning(message: 'Nenhuma categoria disponível.');
      return;
    }
    final selecionada = await showCategoriaSelectSheet(
      context: context,
      title: 'Categoria',
      categorias: items,
      selected: items.where((c) => c.id == _idCategoria).firstOrNull,
    );
    if (selecionada == null) return;
    setState(() => _idCategoria = selecionada.id);
  }

  Future<void> _escolherLocal() async {
    final items = _lookups?.locais ?? [];
    final selecionado = await showAppSelectSheet<LocalModel>(
      context: context,
      title: 'Estabelecimento',
      items: items,
      labelOf: (c) => c.nome ?? '',
      selected: items.where((c) => c.id == _idLocal).firstOrNull,
      leadingOf: (_) => Icon(Phosphor.storefront, color: DinixColors.primary),
    );
    if (selecionado == null) return;
    setState(() => _idLocal = selecionado.id);
  }

  Widget _campoDestino() {
    final credito = FormaPagamento.usaCartao(_formaPagamento);
    if (credito) {
      final cartao = _lookups?.cartoes.where((c) => c.id == _idCartao).firstOrNull;
      return cadastroSecao(
        'Cartão',
        cadastroBotaoSeletor(
          tituloVazio: 'Selecionar cartão',
          valor: cartao?.nome,
          leading: cartao == null
              ? Icon(Phosphor.creditCard, color: DinixColors.primary)
              : bancoIcon(banco: cartao.banco ?? cartao.nome, size: 28),
          onTap: _escolherCartao,
        ),
      );
    }

    final conta = _lookups?.contas.where((c) => c.id == _idConta).firstOrNull;
    return cadastroSecao(
      'Conta',
      cadastroBotaoSeletor(
        tituloVazio: 'Selecionar conta',
        valor: conta?.nome,
        leading: conta == null
            ? Icon(Phosphor.wallet, color: DinixColors.primary)
            : bancoIcon(banco: conta.nomeBanco ?? conta.nome, size: 28),
        onTap: _escolherConta,
      ),
    );
  }

  void _salvarCadastro() {
    if (!validarFormularioComFeedback(_formKey)) return;
    if (_idCategoria == null || _idCategoria!.isEmpty) {
      showToastWarning(message: 'Selecione uma categoria');
      return;
    }
    final credito = FormaPagamento.usaCartao(_formaPagamento);
    if (!_isEdit) {
      if (credito && (_idCartao == null || _idCartao!.isEmpty)) {
        showToastWarning(message: 'Selecione um cartão');
        return;
      }
      if (!credito && (_idConta == null || _idConta!.isEmpty)) {
        showToastWarning(message: 'Selecione uma conta');
        return;
      }
    }

    final valor = (parseValor(_valorController.text) ?? kCadastroValorPadrao)
        .clamp(kCadastroValorMinimo, kCadastroValorMaximo)
        .toDouble();

    bloc.add(
      CadastroCompraSaveEvent(
        compra: CompraModel(
          id: widget.compra?.id,
          descricao: _descricaoForm.value.trim(),
          dataCompra: dateTimeParaIso(_dataCompra),
          horaCompra: widget.compra?.horaCompra ?? horaAtual(),
          valorTotal: valor,
          idCategoria: _idCategoria,
          idLocal: _idLocal,
          formaPagamento: _formaPagamento,
          idConta: credito ? null : _idConta,
          idCartaoCredito: credito ? _idCartao : null,
          observacoes:
              _obsForm.value.trim().isEmpty ? null : _obsForm.value.trim(),
          qtdParcelas: credito ? _parcelas : 1,
          dataPrimeiraParcela:
              credito && _parcelas > 1 ? dateTimeParaIso(_dataCompra) : null,
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao() async {
    final id = widget.compra?.id;
    if (id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Estornar compra',
      message: 'A compra será removida. Deseja continuar?',
      confirmLabel: 'Remover',
      destructive: true,
    );
    if (ok == true) bloc.add(CadastroCompraDeleteEvent(id: id));
  }

  void _onState(CadastroCompraState state) {
    if (state is CadastroCompraReadyState) {
      setState(() => _lookups = state.lookups);
    }
    if (state is CadastroCompraSuccessState) {
      showToastSuccess(
        message: _isEdit ? 'Compra atualizada' : 'Compra lançada',
      );
      Navigator.of(context).pop(true);
    }
    if (state is CadastroCompraDeletedState) {
      showToastSuccess(message: 'Compra removida');
      Navigator.of(context).pop(true);
    }
    if (state is CadastroCompraErrorState) {
      showAppErrorSnackbar(state.errorModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final credito = FormaPagamento.usaCartao(_formaPagamento);
    final categoria =
        _lookups?.categorias.where((c) => c.id == _idCategoria).firstOrNull;
    final local = _lookups?.locais.where((c) => c.id == _idLocal).firstOrNull;

    return scaffold(
      title: _isEdit ? 'Editar compra' : 'Nova compra',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      drawerColor: DinixColors.textPrimary,
      body: BlocConsumer<CadastroCompraBloc, CadastroCompraState>(
        bloc: bloc,
        listener: (_, state) => _onState(state),
        builder: (context, state) {
          if (state is CadastroCompraLoadingState ||
              state is CadastroCompraInitialState) {
            return appLoadingDinix();
          }
          return Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                if (!_isEdit)
                  cadastroCampoValor(
                    titulo: 'Valor',
                    controller: _valorController,
                    focusNode: _valorFocus,
                    validator: validateValor,
                    onChanged: () => setState(() {}),
                  ),
                cadastroSecao(
                  'O que foi comprado',
                  _descricaoForm.formulario,
                ),
                cadastroCampoQuando(
                  data: _dataCompra,
                  onChanged: (d) => setState(() => _dataCompra = d),
                ),
                if (!_isEdit)
                  cadastroSecao(
                    'Pagamento',
                    cadastroGradeChips(
                      [
                        for (final forma in FormaPagamento.valores)
                          cadastroChip(
                            label: FormaPagamento.rotulo(forma),
                            selecionado: _formaPagamento == forma,
                            onTap: () => _selecionarPagamento(forma),
                          ),
                      ],
                      colunas: 2,
                    ),
                  ),
                if (!_isEdit) _campoDestino(),
                if (!_isEdit && credito)
                  cadastroCampoInteiro(
                    titulo: 'Parcelas',
                    valor: _parcelas,
                    min: 1,
                    max: 48,
                    onChanged: (v) => setState(() => _parcelas = v),
                    rotulo: (v) => '${v}x',
                  ),
                cadastroSecao(
                  'Categoria',
                  cadastroBotaoSeletor(
                    tituloVazio: 'Selecionar categoria',
                    valor: categoria?.nome,
                    leading: Icon(
                      iconeDaCategoria(categoria),
                      color: DinixColors.primary,
                    ),
                    onTap: _escolherCategoria,
                  ),
                ),
                cadastroSecao(
                  'Estabelecimento',
                  cadastroBotaoSeletor(
                    tituloVazio: 'Selecionar estabelecimento',
                    valor: local?.nome,
                    leading: Icon(
                      Phosphor.storefront,
                      color: DinixColors.primary,
                    ),
                    onTap: _escolherLocal,
                    onClear: _idLocal == null
                        ? null
                        : () => setState(() => _idLocal = null),
                  ),
                ),
                cadastroSecao('Observações', _obsForm.formulario),
                appSizedBox(height: AppSpacing.medium),
                appElevatedButtonDinix(
                  title: _isEdit ? AppStrings.salvar : 'Lançar compra',
                  onTap: _salvarCadastro,
                  height: 52,
                ),
                if (_isEdit) ...[
                  appSizedBox(height: AppSpacing.normal),
                  appElevatedButtonDinix(
                    title: 'Estornar',
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
    _valorFocus.removeListener(_aoFocarValor);
    _valorController.dispose();
    _valorFocus.dispose();
    bloc.close();
    super.dispose();
  }
}

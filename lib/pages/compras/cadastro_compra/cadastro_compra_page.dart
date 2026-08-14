import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/compra_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/local_model.dart';
import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_bloc.dart';
import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_event.dart';
import 'package:app_dinix/pages/compras/cadastro_compra/cadastro_compra_state.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_form_field_dinix.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_select_sheet.dart';
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

  late final AppFormField _descricaoForm;
  late final AppFormField _dataForm;
  late final AppFormField _valorForm;
  late final AppFormField _categoriaForm;
  late final AppFormField _localForm;
  late final AppFormField _pagamentoForm;
  late final AppFormField _destinoForm;
  late final AppFormField _parcelasForm;
  late final AppFormField _obsForm;
  late final bool _isEdit;

  CadastroCompraLookups? _lookups;
  String? _idCategoria;
  String? _idLocal;
  String _formaPagamento = FormaPagamento.pix;
  String? _idConta;
  String? _idCartao;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.compra?.id != null && widget.compra!.id!.isNotEmpty;
    _idCategoria = widget.compra?.idCategoria;
    _idLocal = widget.compra?.idLocal;
    _formaPagamento = widget.compra?.formaPagamento ?? FormaPagamento.pix;
    _idConta = widget.compra?.idConta;
    _idCartao = widget.compra?.idCartaoCredito;
    _criarCampos();
    _preencher();
    bloc.add(CadastroCompraLoadEvent());
  }

  void _criarCampos() {
    _descricaoForm = criarCampoDinix(
      context: context,
      hint: 'Descrição',
      icon: Phosphor.shoppingBag,
      validator: (v) => validateObrigatorio(v, campo: 'Descrição'),
    );
    _dataForm = criarCampoDinix(
      context: context,
      hint: 'Data da compra',
      icon: Phosphor.calendarBlank,
      textInputType: TextInputType.number,
      textInputFormatter: AppFormFormatters.data,
      validator: validateDataBr,
    );
    _valorForm = criarCampoDinix(
      context: context,
      hint: 'Valor total',
      icon: Phosphor.money,
      textInputType: TextInputType.number,
      textInputFormatter: AppFormFormatters.valor,
      validator: _isEdit ? null : validateValor,
    );
    _categoriaForm = criarCampoDinix(
      context: context,
      hint: 'Categoria',
      icon: Phosphor.tag,
      showKeyboard: false,
      onTap: _escolherCategoria,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
      validator: (v) => validateObrigatorio(v, campo: 'Categoria'),
    );
    _localForm = criarCampoDinix(
      context: context,
      hint: 'Estabelecimento (opcional)',
      icon: Phosphor.storefront,
      showKeyboard: false,
      onTap: _escolherLocal,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
    );
    _pagamentoForm = criarCampoDinix(
      context: context,
      hint: 'Forma de pagamento',
      icon: Phosphor.wallet,
      showKeyboard: false,
      onTap: _isEdit ? null : _escolherPagamento,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
    );
    _destinoForm = criarCampoDinix(
      context: context,
      hint: FormaPagamento.usaCartao(_formaPagamento) ? 'Cartão' : 'Conta',
      icon: Phosphor.wallet,
      showKeyboard: false,
      onTap: _isEdit ? null : _escolherDestino,
      suffixIcon: Icon(Phosphor.caretDown, color: AppColors.grey400),
      validator: _isEdit ? null : (v) => validateObrigatorio(v, campo: 'Pagamento'),
    );
    _parcelasForm = criarCampoDinix(
      context: context,
      hint: 'Quantidade de parcelas',
      icon: Phosphor.numberOne,
      textInputType: TextInputType.number,
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
    _dataForm.controller.text = isoParaBr(compra?.dataCompra ?? dataHojeIso());
    _pagamentoForm.controller.text = FormaPagamento.rotulo(_formaPagamento);
    _parcelasForm.controller.text = '${compra?.qtdParcelas ?? 1}';
    if (compra == null) return;
    _descricaoForm.controller.text = compra.descricao ?? '';
    if (compra.valorTotal != null) {
      _valorForm.controller.text = formataMoedaCampo(compra.valorTotal);
    }
    _obsForm.controller.text = compra.observacoes ?? '';
  }

  void _aplicarLookups(CadastroCompraLookups lookups) {
    _lookups = lookups;
    final categoria = lookups.categorias.where((c) => c.id == _idCategoria).firstOrNull;
    if (categoria != null) _categoriaForm.controller.text = categoria.nome ?? '';
    final local = lookups.locais.where((c) => c.id == _idLocal).firstOrNull;
    if (local != null) _localForm.controller.text = local.nome ?? '';
    _atualizarDestinoLabel();
  }

  void _atualizarDestinoLabel() {
    if (FormaPagamento.usaCartao(_formaPagamento)) {
      final cartao = _lookups?.cartoes.where((c) => c.id == _idCartao).firstOrNull;
      _destinoForm.controller.text = cartao?.nome ?? '';
    } else {
      final conta = _lookups?.contas.where((c) => c.id == _idConta).firstOrNull;
      _destinoForm.controller.text = conta?.nome ?? '';
    }
  }

  Future<void> _escolherCategoria() async {
    final items = _lookups?.categorias ?? [];
    if (items.isEmpty) return;
    final selecionada = await showAppSelectSheet<CategoriaModel>(
      context: context,
      title: 'Categoria',
      items: items,
      labelOf: (c) => c.nome ?? '',
      selected: items.where((c) => c.id == _idCategoria).firstOrNull,
    );
    if (selecionada == null) return;
    setState(() {
      _idCategoria = selecionada.id;
      _categoriaForm.controller.text = selecionada.nome ?? '';
    });
  }

  Future<void> _escolherLocal() async {
    final items = _lookups?.locais ?? [];
    final selecionado = await showAppSelectSheet<LocalModel>(
      context: context,
      title: 'Estabelecimento',
      items: items,
      labelOf: (c) => c.nome ?? '',
      selected: items.where((c) => c.id == _idLocal).firstOrNull,
    );
    if (selecionado == null) return;
    setState(() {
      _idLocal = selecionado.id;
      _localForm.controller.text = selecionado.nome ?? '';
    });
  }

  Future<void> _escolherPagamento() async {
    final selecionada = await showAppSelectSheet<String>(
      context: context,
      title: 'Forma de pagamento',
      items: FormaPagamento.valores,
      labelOf: FormaPagamento.rotulo,
      selected: _formaPagamento,
    );
    if (selecionada == null) return;
    setState(() {
      _formaPagamento = selecionada;
      _pagamentoForm.controller.text = FormaPagamento.rotulo(selecionada);
      if (FormaPagamento.usaCartao(selecionada)) {
        _idConta = null;
      } else {
        _idCartao = null;
        _parcelasForm.controller.text = '1';
      }
      _atualizarDestinoLabel();
    });
  }

  Future<void> _escolherDestino() async {
    if (FormaPagamento.usaCartao(_formaPagamento)) {
      final items = _lookups?.cartoes ?? [];
      if (items.isEmpty) {
        showToastWarning(message: 'Cadastre um cartão em Carteiras antes.');
        return;
      }
      final selecionado = await showAppSelectSheet<CartaoCreditoModel>(
        context: context,
        title: 'Cartão',
        items: items,
        labelOf: (c) => c.nome ?? '',
        selected: items.where((c) => c.id == _idCartao).firstOrNull,
      );
      if (selecionado == null) return;
      setState(() {
        _idCartao = selecionado.id;
        _destinoForm.controller.text = selecionado.nome ?? '';
      });
      return;
    }

    final items = _lookups?.contas ?? [];
    if (items.isEmpty) {
      showToastWarning(message: 'Cadastre uma conta em Carteiras antes.');
      return;
    }
    final selecionada = await showAppSelectSheet<ContaModel>(
      context: context,
      title: 'Conta',
      items: items,
      labelOf: (c) => c.nome ?? '',
      selected: items.where((c) => c.id == _idConta).firstOrNull,
    );
    if (selecionada == null) return;
    setState(() {
      _idConta = selecionada.id;
      _destinoForm.controller.text = selecionada.nome ?? '';
    });
  }

  void _salvarCadastro() {
    if (!validarFormularioComFeedback(_formKey)) return;
    final credito = FormaPagamento.usaCartao(_formaPagamento);
    final parcelas = int.tryParse(_parcelasForm.value.trim()) ?? 1;
    bloc.add(
      CadastroCompraSaveEvent(
        compra: CompraModel(
          id: widget.compra?.id,
          descricao: _descricaoForm.value.trim(),
          dataCompra: brParaIso(_dataForm.value),
          horaCompra: widget.compra?.horaCompra ?? horaAtual(),
          valorTotal: parseValor(_valorForm.value),
          idCategoria: _idCategoria,
          idLocal: _idLocal,
          formaPagamento: _formaPagamento,
          idConta: credito ? null : _idConta,
          idCartaoCredito: credito ? _idCartao : null,
          observacoes: _obsForm.value.trim().isEmpty ? null : _obsForm.value.trim(),
          qtdParcelas: credito ? parcelas : 1,
          dataPrimeiraParcela: credito && parcelas > 1 ? brParaIso(_dataForm.value) : null,
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
    if (state is CadastroCompraReadyState) _aplicarLookups(state.lookups);
    if (state is CadastroCompraSuccessState) {
      showToastSuccess(message: _isEdit ? 'Compra atualizada' : 'Compra lançada');
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
          if (state is CadastroCompraLoadingState || state is CadastroCompraInitialState) {
            return appLoadingDinix();
          }
          return Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _descricaoForm.formulario,
                _dataForm.formulario,
                if (!_isEdit) _valorForm.formulario,
                _categoriaForm.formulario,
                _localForm.formulario,
                _pagamentoForm.formulario,
                if (!_isEdit) _destinoForm.formulario,
                if (!_isEdit && credito) _parcelasForm.formulario,
                _obsForm.formulario,
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
    bloc.close();
    super.dispose();
  }
}

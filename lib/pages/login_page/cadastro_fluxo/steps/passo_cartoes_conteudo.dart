import 'package:app_dinix/app_config/bancos_catalogo.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/cadastro_fluxo_dados.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class PassoCartoesConteudo extends StatelessWidget {
  final List<BancoOpcao> bancosDisponiveis;
  final List<CartaoFluxoDraft> cartoes;
  final ValueChanged<BancoOpcao> onToggle;
  final void Function(
    CartaoFluxoDraft cartao, {
    double? limite,
    int? diaFechamento,
    int? diaVencimento,
    bool limiteAlterado,
    bool fechamentoAlterado,
    bool vencimentoAlterado,
  }) onCartaoChanged;

  const PassoCartoesConteudo({
    super.key,
    required this.bancosDisponiveis,
    required this.cartoes,
    required this.onToggle,
    required this.onCartaoChanged,
  });

  CartaoFluxoDraft? _cartaoDe(BancoOpcao banco) {
    for (final cartao in cartoes) {
      if (cartao.banco.nome == banco.nome) return cartao;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (bancosDisponiveis.isEmpty) {
      return appText(
        'Cadastre ao menos uma conta no passo anterior para adicionar cartões.',
        color: AppColors.grey400,
        textAlign: TextAlign.center,
      );
    }

    return Column(
      children: bancosDisponiveis.map((banco) {
        final cartao = _cartaoDe(banco);
        final ativo = cartao != null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: DinixColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.card),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  value: ativo,
                  activeThumbColor: DinixColors.primary,
                  title: Row(
                    children: [
                      bancoIcon(
                        banco: banco.nome,
                        size: 32,
                        gradient: banco.gradiente,
                      ),
                      appSizedBox(width: AppSpacing.normal),
                      Expanded(
                        child: appText(
                          'Cartão ${banco.nome}',
                          color: DinixColors.textPrimary,
                          fontSize: AppFontSizes.small,
                        ),
                      ),
                    ],
                  ),
                  subtitle: appText(
                    ativo ? 'Preencha os dados abaixo' : 'Toque para incluir',
                    color: AppColors.grey400,
                    fontSize: AppFontSizes.verySmall,
                  ),
                  onChanged: (_) => onToggle(banco),
                ),
                if (ativo)
                  _CartaoCampos(
                    key: ValueKey(cartao.banco.nome),
                    cartao: cartao,
                    onChanged: onCartaoChanged,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CartaoCampos extends StatefulWidget {
  final CartaoFluxoDraft cartao;
  final void Function(
    CartaoFluxoDraft cartao, {
    double? limite,
    int? diaFechamento,
    int? diaVencimento,
    bool limiteAlterado,
    bool fechamentoAlterado,
    bool vencimentoAlterado,
  }) onChanged;

  const _CartaoCampos({
    super.key,
    required this.cartao,
    required this.onChanged,
  });

  @override
  State<_CartaoCampos> createState() => _CartaoCamposState();
}

class _CartaoCamposState extends State<_CartaoCampos> {
  late final TextEditingController _limiteController;
  late final TextEditingController _fechamentoController;
  late final TextEditingController _vencimentoController;

  @override
  void initState() {
    super.initState();
    _limiteController = TextEditingController(
      text: widget.cartao.limite > 0 ? formataMoedaCampo(widget.cartao.limite) : '',
    );
    _fechamentoController = TextEditingController(
      text: widget.cartao.diaFechamento?.toString() ?? '',
    );
    _vencimentoController = TextEditingController(
      text: widget.cartao.diaVencimento?.toString() ?? '',
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.grey400),
      filled: true,
      fillColor: DinixColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: AppColors.grey800),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: AppColors.grey800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(
          color: DinixColors.primary,
          width: AppBorder.active,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          appText(
            'Limite',
            color: AppColors.grey400,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: 6),
          TextFormField(
            controller: _limiteController,
            keyboardType: TextInputType.number,
            inputFormatters: [AppFormFormatters.valor],
            style: const TextStyle(color: DinixColors.textPrimary),
            decoration: _decoration('0,00').copyWith(prefixText: 'R\$ '),
            onChanged: (v) => widget.onChanged(
              widget.cartao,
              limite: parseValor(v) ?? 0,
              limiteAlterado: true,
            ),
          ),
          appSizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    appText(
                      'Fechamento',
                      color: AppColors.grey400,
                      fontSize: AppFontSizes.verySmall,
                    ),
                    appSizedBox(height: 6),
                    TextFormField(
                      controller: _fechamentoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      style: const TextStyle(color: DinixColors.textPrimary),
                      decoration: _decoration('Ex: 10'),
                      onChanged: (v) => widget.onChanged(
                        widget.cartao,
                        diaFechamento: v.trim().isEmpty ? null : int.tryParse(v.trim()),
                        fechamentoAlterado: true,
                      ),
                    ),
                  ],
                ),
              ),
              appSizedBox(width: AppSpacing.normal),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    appText(
                      'Vencimento',
                      color: AppColors.grey400,
                      fontSize: AppFontSizes.verySmall,
                    ),
                    appSizedBox(height: 6),
                    TextFormField(
                      controller: _vencimentoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      style: const TextStyle(color: DinixColors.textPrimary),
                      decoration: _decoration('Ex: 17'),
                      onChanged: (v) => widget.onChanged(
                        widget.cartao,
                        diaVencimento: v.trim().isEmpty ? null : int.tryParse(v.trim()),
                        vencimentoAlterado: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _limiteController.dispose();
    _fechamentoController.dispose();
    _vencimentoController.dispose();
    super.dispose();
  }
}

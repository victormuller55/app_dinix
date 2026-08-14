import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/cadastro_fluxo_dados.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class PassoSaldoConteudo extends StatelessWidget {
  final List<ContaFluxoDraft> contas;
  final void Function(int index, double saldo) onSaldoChanged;

  const PassoSaldoConteudo({
    super.key,
    required this.contas,
    required this.onSaldoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(contas.length, (index) {
        final conta = contas[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + index * 80),
          curve: Curves.easeOutCubic,
          builder: (_, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 16 * (1 - value)),
              child: child,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SaldoContaCampo(
              key: ValueKey(conta.banco.nome),
              conta: conta,
              onChanged: (saldo) => onSaldoChanged(index, saldo),
            ),
          ),
        );
      }),
    );
  }
}

class _SaldoContaCampo extends StatefulWidget {
  final ContaFluxoDraft conta;
  final ValueChanged<double> onChanged;

  const _SaldoContaCampo({
    super.key,
    required this.conta,
    required this.onChanged,
  });

  @override
  State<_SaldoContaCampo> createState() => _SaldoContaCampoState();
}

class _SaldoContaCampoState extends State<_SaldoContaCampo> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: formataMoedaCampo(widget.conta.saldo),
    );
  }

  @override
  void didUpdateWidget(covariant _SaldoContaCampo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conta.saldo != widget.conta.saldo &&
        widget.conta.saldo != (parseValor(_controller.text) ?? 0)) {
      _controller.text = formataMoedaCampo(widget.conta.saldo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final banco = widget.conta.banco;
    return Material(
      color: DinixColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            bancoIcon(
              banco: banco.nome,
              size: 40,
              gradient: banco.gradiente,
            ),
            appSizedBox(width: AppSpacing.normal),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appText(
                    banco.nome,
                    bold: true,
                    color: DinixColors.textPrimary,
                    fontSize: AppFontSizes.small,
                  ),
                  appSizedBox(height: 8),
                  TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [MoedaInputFormatter()],
                    style: const TextStyle(color: DinixColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '0,00',
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
                      prefixText: 'R\$ ',
                      prefixStyle: const TextStyle(color: DinixColors.textPrimary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (v) => widget.onChanged(parseValor(v) ?? 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

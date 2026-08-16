import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

const kCadastroValorMinimo = 0.01;
const kCadastroValorMaximo = 99999999.99;
const kCadastroValorPadrao = 5.0;
const kCadastroValorPasso = 1.0;

void aplicarTextoValor(TextEditingController controller, double valor) {
  final texto = formataMoedaCampo(valor);
  if (controller.text == texto) return;
  controller.value = TextEditingValue(
    text: texto,
    selection: TextSelection.collapsed(offset: texto.length),
  );
}

void normalizarValorCampo(
  TextEditingController controller, {
  double min = kCadastroValorMinimo,
  double max = kCadastroValorMaximo,
  double? fallback,
}) {
  final parsed = parseValor(controller.text);
  if (parsed == null || parsed < min) {
    aplicarTextoValor(controller, fallback ?? min);
    return;
  }
  if (parsed > max) {
    aplicarTextoValor(controller, max);
  }
}

void ajustarValorCampo(
  TextEditingController controller, {
  required double delta,
  double min = kCadastroValorMinimo,
  double max = kCadastroValorMaximo,
  double padrao = kCadastroValorPadrao,
}) {
  final atual = parseValor(controller.text) ?? padrao;
  final novo = (atual + delta).clamp(min, max).toDouble();
  aplicarTextoValor(controller, novo);
}

Widget cadastroSecao(String titulo, Widget child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        appText(
          titulo,
          color: DinixColors.textMuted,
          fontSize: AppFontSizes.verySmall,
          bold: true,
        ),
        appSizedBox(height: 8),
        child,
      ],
    ),
  );
}

Widget cadastroChip({
  required String label,
  required bool selecionado,
  required VoidCallback onTap,
  IconData? icon,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: AppDuration.fast,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selecionado ? DinixColors.primary : DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selecionado ? DinixColors.primary : AppColors.grey800,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: selecionado ? DinixColors.onPrimary : DinixColors.primary,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: appText(
              label,
              bold: selecionado,
              color: selecionado ? DinixColors.onPrimary : DinixColors.textPrimary,
              fontSize: AppFontSizes.verySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget cadastroGradeChips(List<Widget> children, {int colunas = 3}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final espaco = 8.0;
      final largura = (constraints.maxWidth - espaco * (colunas - 1)) / colunas;
      return Wrap(
        spacing: espaco,
        runSpacing: espaco,
        children: [
          for (final child in children)
            SizedBox(width: largura, child: child),
        ],
      );
    },
  );
}

Widget cadastroBotaoSeletor({
  required String tituloVazio,
  required String? valor,
  required Widget? leading,
  required VoidCallback onTap,
  VoidCallback? onClear,
}) {
  final preenchido = valor != null && valor.isNotEmpty;
  return Material(
    color: DinixColors.surfaceElevated,
    borderRadius: BorderRadius.circular(AppRadius.card),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: preenchido ? DinixColors.primary : AppColors.grey800,
            width: preenchido ? AppBorder.active : 1,
          ),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading,
              appSizedBox(width: AppSpacing.normal),
            ],
            Expanded(
              child: appText(
                preenchido ? valor : tituloVazio,
                bold: preenchido,
                color: preenchido ? DinixColors.textPrimary : DinixColors.textMuted,
                fontSize: AppFontSizes.small,
              ),
            ),
            if (preenchido && onClear != null)
              IconButton(
                onPressed: onClear,
                visualDensity: VisualDensity.compact,
                icon: Icon(Phosphor.x, color: DinixColors.textMuted, size: 18),
              )
            else
              Icon(Phosphor.caretDown, color: DinixColors.textMuted, size: 18),
          ],
        ),
      ),
    ),
  );
}

Widget cadastroBotaoStepper({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Material(
    color: DinixColors.surfaceElevated,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Icon(icon, color: DinixColors.primary, size: 28),
      ),
    ),
  );
}

Widget cadastroCampoValor({
  required String titulo,
  required TextEditingController controller,
  FocusNode? focusNode,
  bool enabled = true,
  bool showSteppers = true,
  double passo = kCadastroValorPasso,
  double min = kCadastroValorMinimo,
  double max = kCadastroValorMaximo,
  double padrao = kCadastroValorPadrao,
  FormFieldValidator<String>? validator,
  VoidCallback? onChanged,
}) {
  return cadastroSecao(
    titulo,
    Row(
      children: [
        if (showSteppers && enabled)
          cadastroBotaoStepper(
            icon: Phosphor.minus,
            onTap: () {
              ajustarValorCampo(
                controller,
                delta: -passo,
                min: min,
                max: max,
                padrao: padrao,
              );
              onChanged?.call();
            },
          ),
        if (showSteppers && enabled) appSizedBox(width: AppSpacing.normal),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: DinixColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: DinixColors.primary,
                width: AppBorder.active,
              ),
            ),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              keyboardType: TextInputType.number,
              inputFormatters: [
                MoedaInputFormatter(max: max),
              ],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: DinixColors.primary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0,00',
                hintStyle: TextStyle(
                  fontFamily: AppFonts.family,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: DinixColors.textMuted,
                ),
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(
                  fontFamily: AppFonts.family,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: DinixColors.primary,
                ),
                // Validação continua no Form; mensagem não aparece sob o campo.
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
              validator: enabled ? validator : null,
              onChanged: (_) => onChanged?.call(),
            ),
          ),
        ),
        if (showSteppers && enabled) appSizedBox(width: AppSpacing.normal),
        if (showSteppers && enabled)
          cadastroBotaoStepper(
            icon: Phosphor.plus,
            onTap: () {
              ajustarValorCampo(
                controller,
                delta: passo,
                min: min,
                max: max,
                padrao: padrao,
              );
              onChanged?.call();
            },
          ),
      ],
    ),
  );
}

Widget cadastroCampoQuando({
  required DateTime data,
  required ValueChanged<DateTime> onChanged,
  String titulo = 'Quando',
}) {
  final agora = DateTime.now();
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final ontem = hoje.subtract(const Duration(days: 1));
  final amanha = hoje.add(const Duration(days: 1));
  final selecionada = DateTime(data.year, data.month, data.day);

  return cadastroSecao(
    titulo,
    cadastroGradeChips(
      [
        cadastroChip(
          label: 'Ontem',
          selecionado: selecionada == ontem,
          onTap: () => onChanged(ontem),
        ),
        cadastroChip(
          label: 'Hoje',
          selecionado: selecionada == hoje,
          onTap: () => onChanged(hoje),
        ),
        cadastroChip(
          label: 'Amanhã',
          selecionado: selecionada == amanha,
          onTap: () => onChanged(amanha),
        ),
      ],
      colunas: 3,
    ),
  );
}

Widget cadastroCampoInteiro({
  required String titulo,
  required int valor,
  required int min,
  required int max,
  required ValueChanged<int> onChanged,
  String Function(int)? rotulo,
}) {
  return cadastroSecao(
    titulo,
    Row(
      children: [
        cadastroBotaoStepper(
          icon: Phosphor.minus,
          onTap: () {
            if (valor <= min) return;
            onChanged(valor - 1);
          },
        ),
        Expanded(
          child: Center(
            child: appText(
              rotulo?.call(valor) ?? '$valor',
              bold: true,
              color: DinixColors.textPrimary,
              fontSize: AppFontSizes.big,
            ),
          ),
        ),
        cadastroBotaoStepper(
          icon: Phosphor.plus,
          onTap: () {
            if (valor >= max) return;
            onChanged(valor + 1);
          },
        ),
      ],
    ),
  );
}

Widget cadastroSwitch({
  required String titulo,
  required String? subtitulo,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      activeThumbColor: DinixColors.primary,
      title: appText(titulo, color: DinixColors.textPrimary),
      subtitle: subtitulo == null
          ? null
          : appText(
              subtitulo,
              color: DinixColors.textMuted,
              fontSize: AppFontSizes.verySmall,
            ),
      onChanged: onChanged,
    ),
  );
}

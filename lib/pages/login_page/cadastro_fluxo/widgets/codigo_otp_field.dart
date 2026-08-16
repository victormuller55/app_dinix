import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/fechar_teclado.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

class CodigoOtpField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? initialValue;

  const CodigoOtpField({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<CodigoOtpField> createState() => _CodigoOtpFieldState();
}

class _CodigoOtpFieldState extends State<CodigoOtpField> {
  static const _tamanho = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;
  late final List<ValueNotifier<bool>> _preenchidos;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_tamanho, (_) => TextEditingController());
    _nodes = List.generate(_tamanho, (_) => FocusNode());
    _preenchidos = List.generate(_tamanho, (_) => ValueNotifier(false));

    final inicial = widget.initialValue ?? '';
    for (var i = 0; i < _tamanho && i < inicial.length; i++) {
      _controllers[i].text = inicial[i];
      _preenchidos[i].value = true;
    }

    for (var i = 0; i < _tamanho; i++) {
      _nodes[i].onKeyEvent = _criarHandlerTecla(i);
    }
  }

  KeyEventResult Function(FocusNode, KeyEvent) _criarHandlerTecla(int index) {
    return (node, event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      if (event.logicalKey != LogicalKeyboardKey.backspace) {
        return KeyEventResult.ignored;
      }
      // Campo já com dígito: deixa o TextField apagar normalmente.
      if (_controllers[index].text.isNotEmpty) {
        return KeyEventResult.ignored;
      }
      if (index <= 0) return KeyEventResult.ignored;

      _controllers[index - 1].clear();
      _preenchidos[index - 1].value = false;
      _focar(index - 1);
      _notificar();
      return KeyEventResult.handled;
    };
  }

  void _notificar() {
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  void _atualizarPreenchido(int index) {
    _preenchidos[index].value = _controllers[index].text.isNotEmpty;
  }

  void _focar(int index) {
    final alvo = index.clamp(0, _tamanho - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _nodes[alvo].requestFocus();
      final text = _controllers[alvo].text;
      if (text.isNotEmpty) {
        _controllers[alvo].selection = TextSelection(
          baseOffset: 0,
          extentOffset: text.length,
        );
      }
    });
  }

  void _aplicarDigitos(int inicio, String digits) {
    for (var i = 0; i < digits.length && inicio + i < _tamanho; i++) {
      final idx = inicio + i;
      _controllers[idx].value = TextEditingValue(
        text: digits[i],
        selection: TextSelection.collapsed(offset: 1),
      );
      _atualizarPreenchido(idx);
    }
  }

  void _onChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      _controllers[index].value = const TextEditingValue(text: '');
      _atualizarPreenchido(index);
      if (index > 0) _focar(index - 1);
      _notificar();
      return;
    }

    if (digits.length > 1) {
      _aplicarDigitos(index, digits);
      final next = (index + digits.length).clamp(0, _tamanho - 1);
      _focar(next);
      _notificar();
      return;
    }

    // Garante 1 dígito mesmo se o campo aceitar texto maior temporariamente.
    if (_controllers[index].text != digits) {
      _controllers[index].value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: 1),
      );
    }
    _atualizarPreenchido(index);

    if (index < _tamanho - 1) {
      _focar(index + 1);
    }
    _notificar();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_tamanho, (index) {
        return ValueListenableBuilder<bool>(
          valueListenable: _preenchidos[index],
          builder: (context, preenchido, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 46,
              height: 54,
              decoration: BoxDecoration(
                color: DinixColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: preenchido ? DinixColors.primary : AppColors.grey800,
                  width: preenchido ? AppBorder.active : AppBorder.thin,
                ),
              ),
              child: TextField(
                controller: _controllers[index],
                focusNode: _nodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                textInputAction: index == _tamanho - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                style: TextStyle(
                  fontFamily: AppFonts.family,
                  color: DinixColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(index == 0 ? _tamanho : 1),
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) => _onChanged(index, v),
                onTap: () {
                  final text = _controllers[index].text;
                  if (text.isEmpty) return;
                  _controllers[index].selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: text.length,
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    fecharTeclado();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    for (final p in _preenchidos) {
      p.dispose();
    }
    super.dispose();
  }
}

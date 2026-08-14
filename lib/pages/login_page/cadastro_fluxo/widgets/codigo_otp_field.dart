import 'package:app_dinix/app_config/const/app_consts.dart';
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

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_tamanho, (_) => TextEditingController());
    _nodes = List.generate(_tamanho, (_) => FocusNode());
    final inicial = widget.initialValue ?? '';
    for (var i = 0; i < _tamanho && i < inicial.length; i++) {
      _controllers[i].text = inicial[i];
    }
  }

  void _notificar() {
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      final chars = value.replaceAll(RegExp(r'\D'), '').split('');
      for (var i = 0; i < chars.length && index + i < _tamanho; i++) {
        _controllers[index + i].text = chars[i];
      }
      final next = (index + chars.length).clamp(0, _tamanho - 1);
      _nodes[next].requestFocus();
    } else if (value.isNotEmpty && index < _tamanho - 1) {
      _nodes[index + 1].requestFocus();
    }
    _notificar();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_tamanho, (index) {
        final preenchido = _controllers[index].text.isNotEmpty;
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
            maxLength: 6,
            style: const TextStyle(
              fontFamily: AppFonts.family,
              color: DinixColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onChanged: (v) => _onChanged(index, v),
            onTap: () => _controllers[index].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controllers[index].text.length,
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }
}

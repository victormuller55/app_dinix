import 'package:flutter/material.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;

class LoginFormField {
  final TextEditingController controller = TextEditingController();
  late final FocusNode focusNode;
  late final Widget formulario;

  LoginFormField({
    required String hint,
    double? width,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    focusNode = FocusNode();
    formulario = _LoginFormFieldWidget(
      controller: controller,
      focusNode: focusNode,
      hint: hint,
      width: width,
      icon: icon,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      validator: validator,
    );
  }

  String get value => controller.text;
}

class _LoginFormFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final double? width;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const _LoginFormFieldWidget({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.width,
    required this.icon,
    required this.obscureText,
    required this.keyboardType,
    required this.textInputAction,
    required this.textCapitalization,
    required this.validator,
  });

  @override
  State<_LoginFormFieldWidget> createState() => _LoginFormFieldWidgetState();
}

class _LoginFormFieldWidgetState extends State<_LoginFormFieldWidget> {
  bool _focused = false;
  bool _hover = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _focused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  Color get _iconColor => _focused ? DinixColors.primary : AppColors.grey400;

  Color get _borderColor {
    if (_focused) return DinixColors.primary;
    if (_hover) return DinixColors.primary.withValues(alpha: 0.55);
    return AppColors.grey800;
  }

  InputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = _border(_borderColor, width: _focused ? AppBorder.active : AppBorder.thin);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: SizedBox(
          width: widget.width ?? double.infinity,
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            validator: widget.validator,
            obscureText: widget.obscureText ? _obscure : false,
            keyboardType: widget.keyboardType ??
                (widget.obscureText
                    ? TextInputType.visiblePassword
                    : TextInputType.emailAddress),
            textInputAction: widget.textInputAction ??
                (widget.obscureText ? TextInputAction.done : TextInputAction.next),
            textCapitalization: widget.textCapitalization,
            style: TextStyle(
              fontFamily: AppFonts.family,
              fontSize: AppFontSizes.small,
              color: DinixColors.textPrimary,
            ),
            cursorColor: DinixColors.primary,
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: DinixColors.surfaceElevated,
              prefixIcon: Icon(widget.icon, color: _iconColor),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Phosphor.eyeSlash
                            : Phosphor.eye,
                        color: _focused ? DinixColors.primary : AppColors.grey400,
                      ),
                    )
                  : null,
              border: border,
              enabledBorder: border,
              focusedBorder: border,
              errorBorder: _border(AppColors.red, width: AppBorder.active),
              focusedErrorBorder: _border(AppColors.red, width: AppBorder.active),
              hintStyle: TextStyle(
                fontSize: AppFontSizes.verySmall,
                color: AppColors.grey400,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ),
    );
  }
}

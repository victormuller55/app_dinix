import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;
import 'package:app_dinix/app_config/const/app_consts.dart';

class CampoDinix {
  final Widget formulario;
  final TextEditingController controller;

  const CampoDinix({
    required this.formulario,
    required this.controller,
  });

  String get value => controller.text;
}

AppFormField criarCampoDinix({
  required BuildContext context,
  required String hint,
  required IconData icon,
  TextInputType? textInputType,
  TextInputFormatter? textInputFormatter,
  String? Function(String?)? validator,
  ValueChanged<String>? onChange,
  int? maxLines,
  Widget? suffixIcon,
  VoidCallback? onTap,
  bool showKeyboard = true,
  bool? showContent,
}) {
  return AppFormField(
    context: context,
    hint: hint,
    icon: Icon(icon, size: 22),
    iconColor: DinixColors.primary,
    inputColor: DinixColors.textPrimary,
    hintColor: DinixColors.textMuted,
    backgroundColor: DinixColors.surfaceElevated,
    borderColor: AppColors.grey800,
    hoverBorderColor: DinixColors.primary,
    radius: AppRadius.input,
    textInputType: textInputType ?? TextInputType.text,
    textInputFormatter: textInputFormatter,
    validator: validator,
    onChange: onChange,
    maxLines: maxLines,
    suffixIcon: suffixIcon,
    onTap: onTap,
    showKeyboard: showKeyboard,
    showContent: showContent,
  );
}

CampoDinix criarCampoComPrefixoDinix({
  required BuildContext context,
  required String hint,
  required Widget prefixIcon,
  TextEditingController? controller,
  TextInputType? textInputType,
  TextInputFormatter? textInputFormatter,
  String? Function(String?)? validator,
  ValueChanged<String>? onChange,
  int? maxLines,
  Widget? suffixIcon,
  VoidCallback? onTap,
  bool showKeyboard = true,
}) {
  final fieldController = controller ?? TextEditingController();
  final focusNode = FocusNode();
  if (!showKeyboard) {
    focusNode.canRequestFocus = false;
  }

  return CampoDinix(
    controller: fieldController,
    formulario: CampoPrefixoDinix(
      controller: fieldController,
      focusNode: focusNode,
      hint: hint,
      prefixIcon: prefixIcon,
      textInputType: textInputType,
      textInputFormatter: textInputFormatter,
      validator: validator,
      onChange: onChange,
      maxLines: maxLines,
      suffixIcon: suffixIcon,
      onTap: onTap,
    ),
  );
}

class CampoPrefixoDinix extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final Widget prefixIcon;
  final TextInputType? textInputType;
  final TextInputFormatter? textInputFormatter;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChange;
  final int? maxLines;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  const CampoPrefixoDinix({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.prefixIcon,
    this.textInputType,
    this.textInputFormatter,
    this.validator,
    this.onChange,
    this.maxLines,
    this.suffixIcon,
    this.onTap,
  });

  @override
  State<CampoPrefixoDinix> createState() => _CampoPrefixoWidgetState();
}

class _CampoPrefixoWidgetState extends State<CampoPrefixoDinix> {
  bool _hover = false;

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
      borderRadius: BorderRadius.circular(AppRadius.input),
    );
  }

  @override
  Widget build(BuildContext context) {
    final normal = _border(AppColors.grey800);
    final active = _border(DinixColors.primary, width: AppBorder.active);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          validator: widget.validator,
          onChanged: widget.onChange,
          onTap: widget.onTap,
          readOnly: widget.onTap != null,
          maxLines: widget.maxLines ?? 1,
          keyboardType: widget.textInputType ?? TextInputType.text,
          inputFormatters: widget.textInputFormatter != null
              ? [widget.textInputFormatter!]
              : null,
          style: TextStyle(
            fontFamily: AppFonts.family,
            fontSize: 13,
            color: DinixColors.textPrimary,
            letterSpacing: 1,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            fillColor: DinixColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
            border: normal,
            enabledBorder: _hover ? active : normal,
            focusedBorder: active,
            errorBorder: _border(AppColors.red, width: AppBorder.active),
            focusedErrorBorder: _border(AppColors.red, width: AppBorder.active),
            hintStyle: TextStyle(
              fontFamily: AppFonts.family,
              fontSize: 13,
              color: DinixColors.textMuted,
              letterSpacing: 1,
            ),
            errorStyle: TextStyle(
              fontFamily: AppFonts.family,
              fontSize: 13,
              color: AppColors.red,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

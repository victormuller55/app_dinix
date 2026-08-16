import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_dinix/app_config/app_platform.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';

Widget appElevatedButtonDinix({
  required String title,
  double? padding,
  double? height,
  double? width,
  double? radius,
  double? fontSize,
  Color? color,
  bool primary = true,
  bool invertedStyle = false,
  bool enableEffects = true,
  required void Function() onTap,
}) {
  var hover = false;
  final borderRadius = radius ?? (isIOSPlatform ? 12.0 : AppRadius.input);
  final buttonHeight = height ?? (isIOSPlatform ? 50.0 : 48.0);
  final label = title.toUpperCase();
  final textSize = fontSize ?? (isIOSPlatform ? 17.0 : AppFontSizes.verySmall);

  return StatefulBuilder(
    builder: (context, setState) {
      final buttonWidth = width ?? MediaQuery.of(context).size.width;

      Widget button = Padding(
        padding: EdgeInsets.only(top: padding ?? 0),
        child: _animatedElevatedButton(
          hover: enableEffects && hover,
          primary: primary,
          invertedStyle: invertedStyle,
          enableEffects: enableEffects,
          label: label,
          onTap: onTap,
          buttonHeight: buttonHeight,
          buttonWidth: buttonWidth,
          borderRadius: borderRadius,
          textSize: textSize,
        ),
      );

      if (!enableEffects) return button;

      return MouseRegion(
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: button,
      );
    },
  );
}

Widget appElevatedButtonDinixTransparent({
  required String title,
  double? width,
  double? height,
  double? radius,
  Color? color,
  required void Function() onTap,
}) {
  return appElevatedButtonDinix(
    title: title,
    width: width,
    height: height,
    radius: radius,
    color: color,
    primary: false,
    onTap: onTap,
  );
}

Widget _animatedElevatedButton({
  required bool hover,
  required bool primary,
  required bool invertedStyle,
  required bool enableEffects,
  required String label,
  required void Function() onTap,
  required double buttonHeight,
  required double buttonWidth,
  required double borderRadius,
  required double textSize,
}) {
  final isOutline = primary
      ? (invertedStyle && !hover)
      : (invertedStyle ? hover : !hover);
  final colors = _resolveElevatedButtonColors(
    primary: primary,
    isOutline: isOutline,
    hover: enableEffects && hover,
  );
  final letterSpacing = isIOSPlatform ? -0.41 : 1.0;
  final fontWeight = isIOSPlatform ? FontWeight.w600 : FontWeight.bold;

  final content = Center(
    child: Text(
      label,
      style: TextStyle(
        color: colors.textColor,
        fontFamily: AppFonts.family,
        fontWeight: fontWeight,
        fontSize: textSize,
        letterSpacing: letterSpacing,
      ),
    ),
  );

  return Container(
    height: buttonHeight,
    width: buttonWidth,
    decoration: BoxDecoration(
      color: colors.backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: colors.borderColor,
        width: colors.borderWidth,
      ),
    ),
    child: enableEffects
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: content,
            ),
          )
        : GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: content,
          ),
  );
}

({Color backgroundColor, Color textColor, Color borderColor, double borderWidth})
    _resolveElevatedButtonColors({
  required bool primary,
  required bool isOutline,
  required bool hover,
}) {
  if (primary) {
    if (isOutline) {
      return (
        backgroundColor: Colors.transparent,
        textColor: DinixColors.primary,
        borderColor: DinixColors.primary,
        borderWidth: AppBorder.thick,
      );
    }

    return (
      backgroundColor:
          hover ? Color.lerp(DinixColors.primary, Colors.white, 0.22)! : DinixColors.primary,
      textColor: DinixColors.onPrimary,
      borderColor: DinixColors.primary,
      borderWidth: 0,
    );
  }

  if (isOutline) {
    return (
      backgroundColor: Colors.transparent,
      textColor: DinixColors.textPrimary,
      borderColor: AppColors.grey700,
      borderWidth: AppBorder.thin,
    );
  }

  return (
    backgroundColor: DinixColors.surfaceElevated,
    textColor: DinixColors.textPrimary,
    borderColor: AppColors.grey800,
    borderWidth: AppBorder.thin,
  );
}

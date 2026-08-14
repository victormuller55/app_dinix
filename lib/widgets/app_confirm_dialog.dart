import 'package:app_dinix/app_config/app_platform.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/widgets/native_ios_ui.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData icon = Phosphor.question,
  String confirmLabel = 'Confirmar',
  String cancelLabel = AppStrings.cancelar,
  bool destructive = false,
}) async {
  if (isIOSPlatform) {
    return showNativeIosConfirm(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    );
  }

  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: DinixColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      title: appText(
        title,
        bold: true,
        color: DinixColors.textPrimary,
        fontSize: AppFontSizes.normal,
      ),
      content: appText(
        message,
        color: AppColors.grey400,
        fontSize: AppFontSizes.verySmall,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            cancelLabel,
            style: TextStyle(color: AppColors.grey400),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel,
            style: TextStyle(
              color: destructive ? AppColors.red : DinixColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

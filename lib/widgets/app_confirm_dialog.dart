import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_dinix/app_config/app_platform.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';

Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData icon = Phosphor.question,
  String confirmLabel = 'Confirmar',
  String cancelLabel = AppStrings.cancelar,
  bool destructive = false,
}) {
  if (isIOSPlatform) {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          TextButton(
            style: destructive
                ? TextButton.styleFrom(foregroundColor: AppColors.red)
                : TextButton.styleFrom(foregroundColor: DinixColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
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

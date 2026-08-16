import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_dinix/app_config/const/app_consts.dart';

Widget emptyMessage({
  required String title,
  String? subtitle,
  IconData icon = Phosphor.tray,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: DinixColors.primary),
        appSizedBox(height: AppSpacing.medium),
        appText(
          title,
          fontSize: AppFontSizes.small,
          bold: true,
          color: DinixColors.textPrimary,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          appSizedBox(height: AppSpacing.small),
          appText(
            subtitle,
            color: DinixColors.textMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    ),
  );
}

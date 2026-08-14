import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_dinix/app_config/const/app_consts.dart';

Widget dinixAddFab({
  required VoidCallback onTap,
  String label = 'Novo',
  Object? heroTag,
}) {
  return FloatingActionButton.extended(
    onPressed: onTap,
    heroTag: heroTag,
    backgroundColor: DinixColors.primary,
    foregroundColor: Colors.black,
    elevation: 4,
    icon: const Icon(Phosphor.plus, size: 26),
    label: appText(
      label,
      fontSize: AppFontSizes.small,
      bold: true,
      color: Colors.black,
    ),
  );
}

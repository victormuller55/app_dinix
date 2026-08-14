import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/widgets/empty.dart';

Widget featurePlaceholder({
  required String title,
  required String subtitle,
  required IconData icon,
}) {
  return Center(
    child: emptyMessage(
      title: title,
      subtitle: subtitle,
      icon: icon,
    ),
  );
}

Widget featureScaffold({
  required String title,
  required String placeholderTitle,
  required String placeholderSubtitle,
  required IconData icon,
}) {
  return scaffold(
    title: title,
    centerTitle: true,
    hideBackIcon: true,
    background: DinixColors.background,
    appBarColor: DinixColors.primaryDark,
    titleColor: DinixColors.textPrimary,
    body: featurePlaceholder(
      title: placeholderTitle,
      subtitle: placeholderSubtitle,
      icon: icon,
    ),
  );
}

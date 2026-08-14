import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

/// Scaffold das abas do menu: logo à esquerda, título centralizado e ações à direita.
Widget dinixMenuScaffold({
  required String title,
  required Widget body,
  List<Widget>? actions,
  VoidCallback? onAdd,
  String addTooltip = 'Adicionar',
  Widget? floatingActionButton,
  Widget? bottomNavigationBar,
  bool extendBody = false,
}) {
  final sideActions = <Widget>[
    ...?actions,
    if (onAdd != null)
      IconButton(
        onPressed: onAdd,
        tooltip: addTooltip,
        icon: const Icon(Phosphor.plus, color: DinixColors.primary, size: 26),
      ),
    if ((actions == null || actions.isEmpty) && onAdd == null)
      const SizedBox(width: 72),
  ];

  return Scaffold(
    backgroundColor: DinixColors.background,
    extendBody: extendBody,
    floatingActionButton: floatingActionButton,
    bottomNavigationBar: bottomNavigationBar,
    appBar: AppBar(
      elevation: 0,
      backgroundColor: DinixColors.primaryDark,
      foregroundColor: DinixColors.textPrimary,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            kLogoAsset,
            height: 26,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
      title: appText(
        title.toUpperCase(),
        color: DinixColors.textPrimary,
        fontSize: AppFontSizes.verySmall,
        bold: true,
      ),
      actions: sideActions,
    ),
    body: SafeArea(child: body),
  );
}

Widget dinixAddAction({
  required VoidCallback onTap,
  String tooltip = 'Adicionar',
}) {
  return IconButton(
    onPressed: onTap,
    tooltip: tooltip,
    icon: const Icon(Phosphor.plus, color: DinixColors.primary, size: 26),
  );
}

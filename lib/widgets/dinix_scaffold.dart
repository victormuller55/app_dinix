import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/app_config/theme/dinix_theme_scope.dart';
import 'package:app_dinix/widgets/app_logo.dart';
import 'package:app_dinix/widgets/dinix_drawer.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

/// Indica se algum drawer Dinix está aberto (ex.: para esconder a CNTabBar no iOS).
final ValueNotifier<bool> dinixDrawerAberto = ValueNotifier<bool>(false);

/// Scaffold das abas do menu: menu drawer à esquerda, título centralizado e ações à direita.
Widget dinixMenuScaffold({
  required String title,
  required Widget body,
  List<Widget>? actions,
  VoidCallback? onAdd,
  String addTooltip = 'Adicionar',
  Widget? floatingActionButton,
  Widget? bottomNavigationBar,
  bool extendBody = false,
  bool showDrawer = true,
}) {
  return Builder(
    builder: (context) {
      DinixThemeScope.depend(context);

      final sideActions = <Widget>[
        ...?actions,
        if (onAdd != null)
          IconButton(
            onPressed: onAdd,
            tooltip: addTooltip,
            icon: Icon(Phosphor.plus, color: DinixColors.primary, size: 26),
          ),
        if ((actions == null || actions.isEmpty) && onAdd == null)
          const SizedBox(width: 72),
      ];

      return Scaffold(
        backgroundColor: DinixColors.background,
        extendBody: extendBody,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        drawer: showDrawer ? const DinixAppDrawer() : null,
        drawerScrimColor: Colors.black.withValues(alpha: 0.55),
        drawerEnableOpenDragGesture: true,
        onDrawerChanged: showDrawer
            ? (aberto) => dinixDrawerAberto.value = aberto
            : null,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: DinixColors.primaryDark,
          foregroundColor: DinixColors.textPrimary,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leadingWidth: 72,
          leading: showDrawer
              ? Builder(
                  builder: (context) {
                    final isLight =
                        Theme.of(context).brightness == Brightness.light;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          tooltip: 'Menu',
                          icon: isLight
                              ? Icon(
                                  Phosphor.list,
                                  color: DinixColors.primary,
                                  size: 28,
                                )
                              : Image.asset(
                                  kLogoAsset,
                                  height: 26,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                        ),
                      ),
                    );
                  },
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Theme.of(context).brightness == Brightness.light
                        ? Icon(
                            Phosphor.list,
                            color: DinixColors.primary,
                            size: 26,
                          )
                        : Image.asset(
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
    },
  );
}

Widget dinixAddAction({
  required VoidCallback onTap,
  String tooltip = 'Adicionar',
}) {
  return IconButton(
    onPressed: onTap,
    tooltip: tooltip,
    icon: Icon(Phosphor.plus, color: DinixColors.primary, size: 26),
  );
}

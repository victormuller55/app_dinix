import 'package:app_dinix/app_config/app_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget _iosRefreshIndicator(
  BuildContext context,
  RefreshIndicatorMode refreshState,
  double pulledExtent,
  double refreshTriggerPullDistance,
  double refreshIndicatorExtent,
) {
  return const Center(
    child: CupertinoActivityIndicator(color: Colors.white, radius: 10),
  );
}

/// Pull-to-refresh: Material no Android, Cupertino no iOS.
Widget listaRefreshBuilder({
  required Future<void> Function() onRefresh,
  required IndexedWidgetBuilder itemBuilder,
  required int itemCount,
  ScrollController? controller,
  EdgeInsetsGeometry? padding,
}) {
  if (isIOSPlatform) {
    return CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
          builder: _iosRefreshIndicator,
        ),
        SliverPadding(
          padding: padding ?? EdgeInsets.zero,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              itemBuilder,
              childCount: itemCount,
            ),
          ),
        ),
      ],
    );
  }

  return RefreshIndicator(
    color: Colors.white,
    backgroundColor: Colors.black,
    onRefresh: onRefresh,
    child: ListView.builder(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    ),
  );
}

/// Estado vazio com pull-to-refresh (mesmo sem itens na lista).
Widget listaRefreshVazia({
  required BuildContext context,
  required Future<void> Function() onRefresh,
  required Widget child,
  EdgeInsetsGeometry? padding,
}) {
  final altura = MediaQuery.sizeOf(context).height * 0.62;
  return listaRefreshBuilder(
    onRefresh: onRefresh,
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
    itemCount: 1,
    itemBuilder: (_, _) => SizedBox(
      height: altura,
      child: Center(child: child),
    ),
  );
}

/// Scroll com pull-to-refresh para conteúdo que não é lista.
Widget dinixRefresh({
  required Future<void> Function() onRefresh,
  required Widget child,
  ScrollController? controller,
  EdgeInsetsGeometry? padding,
}) {
  if (isIOSPlatform) {
    return CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
          builder: _iosRefreshIndicator,
        ),
        SliverPadding(
          padding: padding ?? EdgeInsets.zero,
          sliver: SliverToBoxAdapter(child: child),
        ),
      ],
    );
  }

  return RefreshIndicator(
    color: Colors.white,
    backgroundColor: Colors.black,
    onRefresh: onRefresh,
    child: SingleChildScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: padding,
      child: child,
    ),
  );
}

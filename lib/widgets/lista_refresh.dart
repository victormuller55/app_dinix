import 'package:app_dinix/app_config/app_platform.dart';
import 'package:app_dinix/app_config/const/dinix_colors.dart';
import 'package:app_dinix/widgets/fade_slide_in.dart';
import 'package:flutter/material.dart';

ScrollPhysics get _refreshPhysics => AlwaysScrollableScrollPhysics(
      parent: isIOSPlatform
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics(),
    );

Widget _refresh({
  required Future<void> Function() onRefresh,
  required Widget child,
}) {
  return RefreshIndicator(
    color: DinixColors.primary,
    backgroundColor: DinixColors.surfaceElevated,
    onRefresh: onRefresh,
    child: child,
  );
}

IndexedWidgetBuilder _comFadeSlide(IndexedWidgetBuilder itemBuilder) {
  return (context, index) => FadeSlideIn(
        index: index,
        child: itemBuilder(context, index),
      );
}

/// Pull-to-refresh no mesmo estilo em iOS e Android.
Widget listaRefreshBuilder({
  required Future<void> Function() onRefresh,
  required IndexedWidgetBuilder itemBuilder,
  required int itemCount,
  ScrollController? controller,
  EdgeInsetsGeometry? padding,
  bool animateItems = true,
}) {
  final builder = animateItems ? _comFadeSlide(itemBuilder) : itemBuilder;
  return _refresh(
    onRefresh: onRefresh,
    child: ListView.builder(
      controller: controller,
      physics: _refreshPhysics,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: builder,
    ),
  );
}

/// Estado vazio com pull-to-refresh, mensagem no centro da área disponível.
Widget listaRefreshVazia({
  required BuildContext context,
  required Future<void> Function() onRefresh,
  required Widget child,
  EdgeInsetsGeometry? padding,
}) {
  final conteudo = Padding(
    padding: padding ?? EdgeInsets.zero,
    child: Center(child: child),
  );

  return LayoutBuilder(
    builder: (_, constraints) {
      final minHeight =
          constraints.maxHeight.isFinite && constraints.maxHeight > 0
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height * 0.62;
      return _refresh(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: _refreshPhysics,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: conteudo,
          ),
        ),
      );
    },
  );
}

/// Scroll com pull-to-refresh para conteúdo que não é lista.
Widget dinixRefresh({
  required Future<void> Function() onRefresh,
  required Widget child,
  ScrollController? controller,
  EdgeInsetsGeometry? padding,
}) {
  return _refresh(
    onRefresh: onRefresh,
    child: SingleChildScrollView(
      controller: controller,
      physics: _refreshPhysics,
      padding: padding,
      child: child,
    ),
  );
}

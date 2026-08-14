import 'package:app_dinix/app_config/app_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Loading nativo: Cupertino no iOS, Material no Android.
/// Sempre branco sobre fundo preto.
Widget appLoadingDinix({Color? color, double? size}) {
  final dimension = size ?? 28.0;
  final Widget indicator;
  if (isIOSPlatform) {
    indicator = CupertinoActivityIndicator(
      color: Colors.white,
      radius: (dimension / 2).clamp(8, 14),
    );
  } else {
    indicator = SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        strokeWidth: dimension <= 20 ? 2 : 2.6,
        color: Colors.white,
      ),
    );
  }

  if (size != null) return indicator;

  return ColoredBox(
    color: Colors.black,
    child: Center(child: indicator),
  );
}

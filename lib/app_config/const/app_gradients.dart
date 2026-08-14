import 'package:flutter/material.dart';
import 'package:app_dinix/app_config/const/dinix_colors.dart';

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [DinixColors.primary, Color(0xFFE65100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      DinixColors.background,
      Color(0xFF1A1208),
      DinixColors.background,
    ],
    stops: [0, 0.55, 1],
  );
}

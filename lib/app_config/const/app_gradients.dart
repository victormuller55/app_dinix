import 'package:flutter/material.dart';
import 'package:app_dinix/app_config/const/dinix_colors.dart';

class AppGradients {
  static LinearGradient get primary => LinearGradient(
        colors: [
          DinixColors.primary,
          Color.lerp(DinixColors.primary, Colors.black, 0.25)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get splash => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          DinixColors.background,
          Color.lerp(DinixColors.background, DinixColors.primary, 0.12)!,
          DinixColors.background,
        ],
        stops: const [0, 0.55, 1],
      );
}

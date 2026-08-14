import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_dinix/app_config/const/app_consts.dart';

const String kLogoAsset = 'assets/images/logo/logo.png';
const String kIconAsset = 'assets/images/logo/icon.png';

Widget appLogoDinix({
  Alignment alignment = Alignment.center,
  double height = 56,
  bool showTagline = false,
  bool useIcon = false,
}) {
  return Align(
    alignment: alignment,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          useIcon ? kIconAsset : kLogoAsset,
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        if (showTagline) ...[
          appSizedBox(height: AppSpacing.small),
          appText(
            'Controle seus gastos',
            fontSize: AppFontSizes.small,
            color: DinixColors.textMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    ),
  );
}

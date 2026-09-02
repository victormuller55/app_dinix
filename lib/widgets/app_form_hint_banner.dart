import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

class AppFormHintBanner extends StatelessWidget {
  final String message;
  final String? highlight;
  final IconData icon;
  final Color? tint;

  const AppFormHintBanner({
    super.key,
    required this.message,
    this.highlight,
    this.icon = Phosphor.info,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final color = tint ?? DinixColors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          appSizedBox(width: AppSpacing.normal),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (highlight != null) ...[
                  appText(
                    highlight!,
                    color: DinixColors.textPrimary,
                    fontSize: AppFontSizes.verySmall,
                    bold: true,
                  ),
                  appSizedBox(height: AppSpacing.small),
                ],
                appText(
                  message,
                  color: DinixColors.textPrimary,
                  fontSize: AppFontSizes.verySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

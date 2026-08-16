import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

class SecaoTitulo extends StatelessWidget {
  final String titulo;
  final IconData? icon;

  const SecaoTitulo(this.titulo, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: DinixColors.primary),
            appSizedBox(width: 8),
          ],
          Expanded(
            child: appText(
              titulo,
              bold: true,
              color: DinixColors.textPrimary,
              fontSize: AppFontSizes.small,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? hint;

  const MetricRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appText(
                  label,
                  color: DinixColors.textMuted,
                  fontSize: AppFontSizes.verySmall,
                ),
                if (hint != null) ...[
                  appSizedBox(height: 2),
                  appText(
                    hint!,
                    color: DinixColors.textMuted,
                    fontSize: 11,
                  ),
                ],
              ],
            ),
          ),
          appText(
            value,
            bold: true,
            color: valueColor ?? DinixColors.textPrimary,
            fontSize: AppFontSizes.small,
          ),
        ],
      ),
    );
  }
}

class BarraLimite extends StatelessWidget {
  final double usado;
  final double limite;
  final Color? color;

  const BarraLimite({
    super.key,
    required this.usado,
    required this.limite,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentual = limite <= 0 ? 0.0 : (usado / limite).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: percentual,
        minHeight: 5,
        color: color ?? DinixColors.primary,
        backgroundColor: AppColors.grey800,
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: child,
    );
  }
}

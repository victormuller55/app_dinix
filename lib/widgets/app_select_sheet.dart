import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_dinix/app_config/const/app_consts.dart';

Future<T?> showAppSelectSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  T? selected,
  Widget Function(T)? leadingOf,
  String? Function(T)? subtitleOf,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: DinixColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
    ),
    builder: (ctx) {
      final maxHeight = MediaQuery.of(ctx).size.height * 0.7;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey700,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: appText(
                    title,
                    bold: true,
                    color: DinixColors.textPrimary,
                    fontSize: AppFontSizes.normal,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];
                    final selectedItem = selected != null && selected == item;
                    final subtitle = subtitleOf?.call(item);
                    return ListTile(
                      leading: leadingOf?.call(item),
                      title: appText(
                        labelOf(item),
                        color: DinixColors.textPrimary,
                        bold: selectedItem,
                      ),
                      subtitle: subtitle == null || subtitle.isEmpty
                          ? null
                          : appText(
                              subtitle,
                              color: DinixColors.textMuted,
                              fontSize: AppFontSizes.verySmall,
                            ),
                      trailing: selectedItem
                          ? Icon(Phosphor.check, color: DinixColors.primary)
                          : null,
                      onTap: () => Navigator.pop(ctx, item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

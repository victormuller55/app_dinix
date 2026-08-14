import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_dinix/app_config/const/app_consts.dart';

Future<T?> showAppSelectSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  T? selected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: DinixColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: appText(
                title,
                bold: true,
                color: DinixColors.textPrimary,
                fontSize: AppFontSizes.normal,
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  final selectedItem = selected == item;
                  return ListTile(
                    title: appText(
                      labelOf(item),
                      color: DinixColors.textPrimary,
                    ),
                    trailing: selectedItem
                        ? const Icon(Phosphor.check, color: DinixColors.primary)
                        : null,
                    onTap: () => Navigator.pop(ctx, item),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

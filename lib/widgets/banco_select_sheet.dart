import 'package:app_dinix/app_config/bancos_catalogo.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

Future<BancoOpcao?> showBancoSelectSheet({
  required BuildContext context,
  BancoOpcao? selected,
}) {
  return showModalBottomSheet<BancoOpcao>(
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
                'Banco',
                bold: true,
                color: DinixColors.textPrimary,
                fontSize: AppFontSizes.normal,
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: BancosCatalogo.populares.length,
                itemBuilder: (_, index) {
                  final banco = BancosCatalogo.populares[index];
                  final selecionado = selected?.nome == banco.nome;
                  return ListTile(
                    leading: bancoIcon(
                      banco: banco.nome,
                      size: 40,
                      gradient: banco.gradiente,
                    ),
                    title: appText(
                      banco.nome,
                      color: DinixColors.textPrimary,
                    ),
                    trailing: selecionado
                        ? Icon(Phosphor.check, color: DinixColors.primary)
                        : null,
                    onTap: () => Navigator.pop(ctx, banco),
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

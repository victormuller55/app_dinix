import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

/// Tela de espera da biometria: fundo do app, logo no centro e loading abaixo.
Widget appBiometriaLockScreen({
  String? mensagem,
  VoidCallback? onTentarNovamente,
  VoidCallback? onUsarSenha,
}) {
  return Scaffold(
    backgroundColor: DinixColors.background,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              appLogoDinix(height: 72, showTagline: true),
              appSizedBox(height: AppSpacing.giant),
              appLoadingDinix(size: 28),
              if (mensagem != null && mensagem.isNotEmpty) ...[
                appSizedBox(height: AppSpacing.big),
                appText(
                  mensagem,
                  color: DinixColors.textMuted,
                  fontSize: AppFontSizes.verySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              if (onTentarNovamente != null || onUsarSenha != null) ...[
                appSizedBox(height: AppSpacing.big),
                if (onTentarNovamente != null)
                  TextButton(
                    onPressed: onTentarNovamente,
                    child: appText(
                      'Tentar novamente',
                      color: DinixColors.primary,
                      bold: true,
                    ),
                  ),
                if (onUsarSenha != null)
                  TextButton(
                    onPressed: onUsarSenha,
                    child: appText(
                      'Entrar com senha',
                      color: DinixColors.textMuted,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

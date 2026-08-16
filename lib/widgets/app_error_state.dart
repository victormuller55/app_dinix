import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

bool isOfflineError(ErrorModel? errorModel) {
  if (errorModel == null) return false;
  if (errorModel.tipo == '0') return true;
  final texto =
      '${errorModel.mensagem ?? ''} ${errorModel.erro ?? ''}'.toLowerCase();
  return texto.contains('internet') ||
      texto.contains('conexão') ||
      texto.contains('conexao') ||
      texto.contains('sem conexão') ||
      texto.contains('network') ||
      texto.contains('socket');
}

/// Estado de erro reutilizável (incluindo sem internet).
Widget appErrorState({
  ErrorModel? errorModel,
  String? title,
  String? subtitle,
  VoidCallback? onRetry,
  String retryLabel = 'Tentar novamente',
  bool? offline,
}) {
  final semInternet = offline ?? isOfflineError(errorModel);
  final titulo = title ??
      (semInternet
          ? 'Sem conexão com a internet'
          : 'Algo deu errado');
  final descricao = subtitle ??
      errorModel?.mensagem?.trim() ??
      (semInternet
          ? 'Verifique sua rede e tente novamente.'
          : 'Não foi possível carregar os dados.');
  final icone = semInternet ? Phosphor.wifiSlash : Phosphor.warningCircle;

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: DinixColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 40, color: DinixColors.primary),
          ),
          appSizedBox(height: AppSpacing.big),
          appText(
            titulo,
            fontSize: AppFontSizes.normal,
            bold: true,
            color: DinixColors.textPrimary,
            textAlign: TextAlign.center,
          ),
          appSizedBox(height: AppSpacing.small),
          appText(
            descricao,
            color: DinixColors.textMuted,
            fontSize: AppFontSizes.small,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            appSizedBox(height: AppSpacing.big),
            appElevatedButtonDinix(
              title: retryLabel,
              onTap: onRetry,
              height: 48,
              width: 220,
            ),
          ],
        ],
      ),
    ),
  );
}

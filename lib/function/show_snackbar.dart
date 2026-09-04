import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/haptic.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

enum _SnackTipo { sucesso, erro, aviso }

void showToastSuccess({required String message}) {
  _mostrar(message: message, tipo: _SnackTipo.sucesso);
}

void showToastError({String? message}) {
  vibrateErrorFeedback();
  _mostrar(
    message: message ?? 'Ocorreu um erro',
    tipo: _SnackTipo.erro,
  );
}

void showToastWarning({required String message}) {
  _mostrar(message: message, tipo: _SnackTipo.aviso);
}

void showAppErrorSnackbar(ErrorModel errorModel) {
  final message = errorModel.mensagem?.trim();
  if (message == null || message.isEmpty) return;
  vibrateErrorFeedback();
  _mostrar(message: message, tipo: _SnackTipo.erro);
}

void showAppErrorFromException(Object error) {
  showAppErrorSnackbar(errorModelFromException(error));
}

void _mostrar({required String message, required _SnackTipo tipo}) {
  final accent = switch (tipo) {
    _SnackTipo.sucesso => const Color(0xFF4CAF50),
    _SnackTipo.erro => const Color(0xFFEF5350),
    _SnackTipo.aviso => DinixColors.primary,
  };
  final icon = switch (tipo) {
    _SnackTipo.sucesso => Phosphor.checkCircle,
    _SnackTipo.erro => Phosphor.warningCircle,
    _SnackTipo.aviso => Phosphor.warning,
  };

  ScaffoldMessenger.of(AppContext.context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 3),
        content: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF2F2F2F),
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: appText(
                    message,
                    color: Colors.white,
                    fontSize: AppFontSizes.small,
                    bold: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
}

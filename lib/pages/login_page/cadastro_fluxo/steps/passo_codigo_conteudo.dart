import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/widgets/codigo_otp_field.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

class PassoCodigoConteudo extends StatelessWidget {
  final String email;
  final String valorInicial;
  final ValueChanged<String> onChanged;
  final VoidCallback? onReenviar;
  final bool reenviando;

  const PassoCodigoConteudo({
    super.key,
    required this.email,
    required this.valorInicial,
    required this.onChanged,
    this.onReenviar,
    this.reenviando = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        appText(
          email,
          color: DinixColors.primary,
          fontSize: AppFontSizes.small,
          textAlign: TextAlign.center,
        ),
        appSizedBox(height: AppSpacing.medium),
        CodigoOtpField(
          initialValue: valorInicial,
          onChanged: onChanged,
        ),
        appSizedBox(height: AppSpacing.medium),
        appText(
          'O código expira em 3 horas. Verifique também a caixa de spam.',
          color: AppColors.grey400,
          fontSize: AppFontSizes.verySmall,
          textAlign: TextAlign.center,
        ),
        if (onReenviar != null) ...[
          appSizedBox(height: AppSpacing.normal),
          reenviando
              ? Center(child: appLoadingDinix(size: 22))
              : appTextButton(
                  text: 'Reenviar código',
                  color: DinixColors.primary,
                  onTap: onReenviar!,
                ),
        ],
      ],
    );
  }
}

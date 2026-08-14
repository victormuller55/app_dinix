import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/widgets/codigo_otp_field.dart';
import 'package:app_dinix/widgets/reenviar_codigo_botao.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

class PassoCodigoConteudo extends StatelessWidget {
  final String email;
  final String valorInicial;
  final ValueChanged<String> onChanged;
  final Future<void> Function()? onReenviar;

  const PassoCodigoConteudo({
    super.key,
    required this.email,
    required this.valorInicial,
    required this.onChanged,
    this.onReenviar,
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
          'O código expira em 3 horas. Você pode pedir um novo a cada 5 minutos. Verifique também a caixa de spam.',
          color: AppColors.grey400,
          fontSize: AppFontSizes.verySmall,
          textAlign: TextAlign.center,
        ),
        if (onReenviar != null) ...[
          appSizedBox(height: AppSpacing.normal),
          ReenviarCodigoBotao(onReenviar: onReenviar!),
        ],
      ],
    );
  }
}

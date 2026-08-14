import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

class PassoConfirmarEmailConteudo extends StatefulWidget {
  final String email;

  const PassoConfirmarEmailConteudo({super.key, required this.email});

  @override
  State<PassoConfirmarEmailConteudo> createState() =>
      _PassoConfirmarEmailConteudoState();
}

class _PassoConfirmarEmailConteudoState extends State<PassoConfirmarEmailConteudo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.08).animate(
            CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
          ),
          child: Container(
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DinixColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.grey800),
            ),
            child: Icon(
              Phosphor.envelopeOpen,
              size: 56,
              color: DinixColors.primary,
            ),
          ),
        ),
        appSizedBox(height: AppSpacing.medium),
        appText(
          widget.email,
          bold: true,
          color: DinixColors.textPrimary,
          textAlign: TextAlign.center,
        ),
        appSizedBox(height: AppSpacing.normal),
        appText(
          'Toque em Continuar para receber o código de verificação no seu e-mail. '
          'O código é válido por 3 horas.',
          color: AppColors.grey400,
          fontSize: AppFontSizes.verySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }
}

import 'package:app_dinix/app_config/const/phosphor_icons.dart';
import 'package:app_dinix/widgets/feature_placeholder.dart';
import 'package:flutter/material.dart';

class ExtratoPage extends StatelessWidget {
  const ExtratoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return featureScaffold(
      title: 'Extrato',
      placeholderTitle: 'Extrato',
      placeholderSubtitle:
          'O histórico completo de movimentações vai aparecer aqui em breve.',
      icon: Phosphor.listBullets,
    );
  }
}

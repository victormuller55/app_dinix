import 'package:flutter/material.dart';
import 'package:app_dinix/widgets/feature_placeholder.dart';
import 'package:app_dinix/app_config/const/phosphor_icons.dart';

class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return featureScaffold(
      title: 'Relatórios',
      placeholderTitle: 'Relatórios',
      placeholderSubtitle: 'Resumo do mês, categorias e patrimônio aparecerão nesta aba.',
      icon: Phosphor.chartLine,
    );
  }
}

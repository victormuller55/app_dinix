import 'package:app_dinix/app_config/bancos_catalogo.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/widgets/banco_icon.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

class PassoContasConteudo extends StatelessWidget {
  final List<BancoOpcao> selecionados;
  final ValueChanged<BancoOpcao> onToggle;

  const PassoContasConteudo({
    super.key,
    required this.selecionados,
    required this.onToggle,
  });

  bool _selecionado(BancoOpcao banco) =>
      selecionados.any((b) => b.nome == banco.nome);

  @override
  Widget build(BuildContext context) {
    final bancos = BancosCatalogo.populares.take(12).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.92,
      ),
      itemCount: bancos.length,
      itemBuilder: (_, index) {
        final banco = bancos[index];
        final ativo = _selecionado(banco);
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 280 + (index * 40)),
          curve: Curves.easeOutBack,
          builder: (_, value, child) => Transform.scale(scale: value, child: child),
          child: Material(
            color: ativo ? banco.corColor.withValues(alpha: 0.18) : DinixColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: InkWell(
              onTap: () => onToggle(banco),
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: ativo ? banco.corColor : AppColors.grey800,
                    width: ativo ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    bancoIcon(
                      banco: banco.nome,
                      size: 36,
                      gradient: banco.gradiente,
                    ),
                    appSizedBox(height: AppSpacing.small),
                    appText(
                      banco.nome,
                      color: DinixColors.textPrimary,
                      fontSize: AppFontSizes.verySmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    if (ativo) ...[
                      appSizedBox(height: 4),
                      Icon(Phosphor.checkCircle, color: banco.corColor, size: 16),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

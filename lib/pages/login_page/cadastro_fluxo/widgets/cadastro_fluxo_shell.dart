import 'package:app_dinix/app_config/app_theme.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/cadastro_fluxo_passo.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CadastroFluxoShell extends StatelessWidget {
  final CadastroFluxoPasso passo;
  final Widget child;
  final String botaoTitulo;
  final VoidCallback onContinuar;
  final VoidCallback? onVoltar;
  final VoidCallback? onPular;
  final bool carregando;

  const CadastroFluxoShell({
    super.key,
    required this.passo,
    required this.child,
    required this.botaoTitulo,
    required this.onContinuar,
    this.onVoltar,
    this.onPular,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kAppSystemUiOverlay,
      child: Scaffold(
        backgroundColor: DinixColors.background,
        appBar: AppBar(
          backgroundColor: DinixColors.primaryDark,
          elevation: 0,
          leading: onVoltar == null
              ? null
              : IconButton(
                  onPressed: onVoltar,
                  icon: const Icon(Phosphor.arrowLeft, color: DinixColors.textPrimary),
                ),
          title: appText(
            'Cadastro',
            color: DinixColors.textPrimary,
            fontSize: AppFontSizes.small,
            bold: true,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: passo.progresso,
                  minHeight: 4,
                  color: DinixColors.primary,
                  backgroundColor: AppColors.grey800,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    appText(
                      passo.titulo,
                      bold: true,
                      color: DinixColors.textPrimary,
                      fontSize: AppFontSizes.medium,
                    ),
                    appSizedBox(height: AppSpacing.small),
                    appText(
                      passo.subtitulo,
                      color: AppColors.grey400,
                      fontSize: AppFontSizes.verySmall,
                    ),
                    appSizedBox(height: AppSpacing.big),
                    child,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (onPular != null) ...[
                    appTextButton(
                      text: 'Pular por agora',
                      color: AppColors.grey400,
                      onTap: () => onPular!(),
                    ),
                    appSizedBox(height: AppSpacing.small),
                  ],
                  carregando
                      ? Center(child: appLoadingDinix(size: 22))
                      : appElevatedButtonDinix(
                          title: botaoTitulo,
                          onTap: onContinuar,
                          height: 52,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

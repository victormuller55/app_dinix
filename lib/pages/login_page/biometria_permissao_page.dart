import 'package:app_dinix/app_config/app_biometria.dart';
import 'package:app_dinix/app_config/app_theme.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/pages/home_shell.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

/// Pedido de permissão de biometria na 1ª vez após login/cadastro no aparelho.
class BiometriaPermissaoPage extends StatefulWidget {
  final VoidCallback? onConcluido;

  const BiometriaPermissaoPage({super.key, this.onConcluido});

  @override
  State<BiometriaPermissaoPage> createState() => _BiometriaPermissaoPageState();
}

class _BiometriaPermissaoPageState extends State<BiometriaPermissaoPage> {
  bool _carregando = false;

  Future<void> _irParaHome() async {
    if (widget.onConcluido != null) {
      widget.onConcluido!();
      return;
    }
    if (!mounted) return;
    open(screen: const HomeShell(), closePrevious: true);
  }

  Future<void> _ativar() async {
    if (_carregando) return;
    setState(() => _carregando = true);
    try {
      final suportado = await dispositivoSuportaBiometria();
      if (!suportado) {
        showToastWarning(
          message:
              'Cadastre Face ID ou digital nas configurações do celular e tente de novo.',
        );
        return;
      }

      final ok = await autenticarBiometria(
        motivo: 'Confirme para ativar o desbloqueio do Dinix',
      );
      if (!ok) {
        showToastWarning(message: 'Não foi possível confirmar a biometria.');
        return;
      }
      await definirBiometriaHabilitada(true);
      await _irParaHome();
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _agoraNao() async {
    if (_carregando) return;
    setState(() => _carregando = true);
    try {
      await definirBiometriaHabilitada(false);
      await _irParaHome();
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kAppSystemUiOverlay,
      child: Scaffold(
        backgroundColor: DinixColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              children: [
                const Spacer(),
                appLogoDinix(height: 56, showTagline: true),
                appSizedBox(height: AppSpacing.giant),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: DinixColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.grey800),
                  ),
                  child: const Icon(
                    Phosphor.fingerprint,
                    size: 44,
                    color: DinixColors.primary,
                  ),
                ),
                appSizedBox(height: AppSpacing.big),
                appText(
                  'Desbloqueie com biometria',
                  bold: true,
                  color: DinixColors.textPrimary,
                  fontSize: AppFontSizes.medium,
                  textAlign: TextAlign.center,
                ),
                appSizedBox(height: AppSpacing.small),
                appText(
                  'Na próxima vez que abrir o app, use a digital ou o Face ID deste celular para entrar mais rápido e com mais segurança.',
                  color: AppColors.grey400,
                  fontSize: AppFontSizes.verySmall,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                appElevatedButtonDinix(
                  title: _carregando ? 'Aguarde...' : 'Ativar biometria',
                  onTap: _carregando ? () {} : _ativar,
                  height: 52,
                ),
                appSizedBox(height: AppSpacing.normal),
                appElevatedButtonDinix(
                  title: 'Agora não',
                  invertedStyle: true,
                  enableEffects: false,
                  onTap: _carregando ? () {} : _agoraNao,
                  height: 52,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Após login/cadastro: pergunta biometria na 1ª vez ou vai direto ao home.
Future<void> navegarAposAutenticacao() async {
  if (await devePerguntarBiometria()) {
    open(screen: const BiometriaPermissaoPage(), closePrevious: true);
    return;
  }
  open(screen: const HomeShell(), closePrevious: true);
}

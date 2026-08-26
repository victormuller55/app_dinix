import 'package:app_dinix/app_config/const/app_api_config.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/abrir_url.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class PoliticaPrivacidadeAceite extends StatefulWidget {
  final bool aceito;
  final ValueChanged<bool> onChanged;

  const PoliticaPrivacidadeAceite({
    super.key,
    required this.aceito,
    required this.onChanged,
  });

  @override
  State<PoliticaPrivacidadeAceite> createState() =>
      _PoliticaPrivacidadeAceiteState();
}

class _PoliticaPrivacidadeAceiteState extends State<PoliticaPrivacidadeAceite> {
  late final TapGestureRecognizer _linkRecognizer;

  @override
  void initState() {
    super.initState();
    _linkRecognizer = TapGestureRecognizer()..onTap = _abrirPolitica;
  }

  Future<void> _abrirPolitica() {
    return abrirUrlExterna(AppApiConfig.privacyPolicyUrl);
  }

  void _alternarAceite() {
    HapticFeedback.selectionClick();
    widget.onChanged(!widget.aceito);
  }

  @override
  void dispose() {
    _linkRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _alternarAceite,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  widget.aceito ? Phosphor.checkSquare : Phosphor.square,
                  color: widget.aceito
                      ? DinixColors.primary
                      : DinixColors.textMuted,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.normal),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: DinixColors.textMuted,
                        fontSize: AppFontSizes.verySmall,
                        fontFamily: AppFonts.family,
                        height: 1.35,
                      ),
                      children: [
                        const TextSpan(text: 'Li e aceito a '),
                        TextSpan(
                          text: 'Política de Privacidade',
                          style: TextStyle(
                            color: DinixColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: DinixColors.primary,
                          ),
                          recognizer: _linkRecognizer,
                        ),
                        const TextSpan(text: ' do Dinix.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: appTextButton(
            text: 'Ler política de privacidade',
            color: DinixColors.primary,
            onTap: _abrirPolitica,
          ),
        ),
      ],
    );
  }
}

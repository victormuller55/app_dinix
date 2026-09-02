import 'package:app_dinix/app_config/const/app_api_config.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/abrir_url.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  void dispose() {
    _linkRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: widget.aceito,
      onChanged: (value) {
        HapticFeedback.selectionClick();
        widget.onChanged(value ?? false);
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
      tileColor: Colors.transparent,
      activeColor: DinixColors.primary,
      checkColor: DinixColors.onPrimary,
      side: BorderSide(color: DinixColors.textMuted, width: 1.6),
      title: Text.rich(
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
    );
  }
}

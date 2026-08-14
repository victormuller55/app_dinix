import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyBiometriaPerguntado = 'biometria_perguntado';
const String _keyBiometriaHabilitada = 'biometria_habilitada';

final LocalAuthentication _auth = LocalAuthentication();

Future<bool> dispositivoSuportaBiometria() async {
  try {
    if (await _auth.isDeviceSupported()) return true;
    if (await _auth.canCheckBiometrics) return true;
    final disponiveis = await _auth.getAvailableBiometrics();
    return disponiveis.isNotEmpty;
  } catch (_) {
    return false;
  }
}

Future<bool> biometriaJaPerguntada() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_keyBiometriaPerguntado) ?? false;
}

Future<bool> biometriaHabilitada() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_keyBiometriaHabilitada) ?? false;
}

Future<void> definirBiometriaHabilitada(bool habilitada) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyBiometriaHabilitada, habilitada);
  await prefs.setBool(_keyBiometriaPerguntado, true);
}

/// Pergunta na 1ª vez no aparelho após login/cadastro (mesmo sem biometria enrolada).
Future<bool> devePerguntarBiometria() async {
  return !(await biometriaJaPerguntada());
}

Future<bool> autenticarBiometria({
  String motivo = 'Confirme sua identidade para abrir o Dinix',
}) async {
  try {
    final suportado = await dispositivoSuportaBiometria();
    if (!suportado) return false;

    return await _auth.authenticate(
      localizedReason: motivo,
      biometricOnly: false,
      persistAcrossBackgrounding: true,
      authMessages: const <AuthMessages>[
        AndroidAuthMessages(
          signInTitle: 'Desbloquear Dinix',
          signInHint: 'Confirme sua identidade',
          cancelButton: 'Cancelar',
        ),
        IOSAuthMessages(
          cancelButton: 'Cancelar',
        ),
      ],
    );
  } on LocalAuthException {
    return false;
  } on PlatformException {
    return false;
  } catch (_) {
    return false;
  }
}

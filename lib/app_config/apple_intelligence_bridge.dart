import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/app_config/app_biometria.dart';
import 'package:app_dinix/app_config/app_platform.dart';
import 'package:app_dinix/app_config/const/app_api_config.dart';
import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const MethodChannel appleIntelligenceChannel = MethodChannel(
  'app_dinix/apple_intelligence',
);

/// Apenas testes: força o envio ao channel nativo fora do iOS.
@visibleForTesting
bool debugForceAppleIntelligence = false;

bool get appleIntelligenceDisponivel =>
    isIOSPlatform || debugForceAppleIntelligence;

class AppleIntelligenceEntityType {
  static const compra = 'compra';
  static const receita = 'receita';
  static const gastoMensal = 'gasto_mensal';
  static const assinatura = 'assinatura';
}

/// Sincroniza a sessão Flutter com o Keychain nativo usado pelos App Intents.
Future<void> syncAppleIntelligenceSession() async {
  if (!appleIntelligenceDisponivel) return;
  final token = await getToken();
  if (token == null || token.isEmpty) {
    await appleIntelligenceChannel.invokeMethod<void>('clearSession');
    return;
  }
  final usuario = await getUsuarioLogado();
  await appleIntelligenceChannel.invokeMethod<void>('syncSession', {
    'token': token,
    'userId': usuario?.id,
    'authDay': todayAuthKey(),
    'deviceId': await getDeviceId(),
    'apiBaseURL': server,
    'clientId': AppApiConfig.clientId,
    'clientSecret': AppApiConfig.clientSecret,
    'appVersion': AppApiConfig.appVersion,
    'biometriaHabilitada': await biometriaHabilitada(),
  });
  await reindexAppleIntelligenceSpotlight();
}

Future<void> clearAppleIntelligenceSession() async {
  if (!appleIntelligenceDisponivel) return;
  await appleIntelligenceChannel.invokeMethod<void>('clearSession');
}

Future<void> setAppleIntelligenceOnScreenEntity({
  required String type,
  required String id,
  String? title,
}) async {
  if (!appleIntelligenceDisponivel) return;
  await appleIntelligenceChannel.invokeMethod<void>('setOnScreenEntity', {
    'type': type,
    'id': id,
    'title': title,
  });
}

Future<void> clearAppleIntelligenceOnScreenEntity() async {
  if (!appleIntelligenceDisponivel) return;
  await appleIntelligenceChannel.invokeMethod<void>('clearOnScreenEntity');
}

Future<Map<String, String>> consumeAppleIntelligencePendingRoute() async {
  if (!appleIntelligenceDisponivel) return const {};
  final raw = await appleIntelligenceChannel.invokeMethod<dynamic>(
    'consumePendingRoute',
  );
  if (raw is Map) {
    return raw.map((key, value) => MapEntry('$key', '$value'));
  }
  return const {};
}

Future<void> reindexAppleIntelligenceSpotlight() async {
  if (!appleIntelligenceDisponivel) return;
  await appleIntelligenceChannel.invokeMethod<void>('reindexSpotlight');
}

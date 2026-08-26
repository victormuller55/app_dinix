/// Credenciais e metadados do client mobile.
class AppApiConfig {
  AppApiConfig._();

  static const String clientId = 'dinix-mobile';
  static const String clientSecret = 'dinix-mobile-client';

  /// Deve acompanhar `version` do `pubspec.yaml` (sem build number).
  static const String appVersion = '1.0.0';

  static const String privacyPolicyUrl =
      'https://convertix.net.br/pages/politica-privacidade-dinix.html';
}

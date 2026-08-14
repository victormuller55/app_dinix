/// Prefetch de lookups após o login. Expandir quando as features existirem.
class ReferenceDataPrefetch {
  ReferenceDataPrefetch._();

  static void agendarDownloadPosLogin() {}

  static Future<void> sincronizar({
    bool forcar = false,
    bool mostrarProgresso = true,
  }) async {}
}

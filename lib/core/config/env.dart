/// Lee las credenciales inyectadas vía
/// `--dart-define-from-file=.dart_defines.json` (ver
/// `.dart_defines.json.example` para las llaves esperadas). Nunca
/// hardcodear valores reales aquí — sección 2 de CLAUDE.md.
abstract final class Env {
  static const _googleOAuthClientIdIos = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_ID_IOS',
  );
  static const _googleOAuthServerClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_SERVER_CLIENT_ID',
  );

  /// Client ID de iOS/macOS (Android se autoconfigura por paquete + SHA-1
  /// registrados en Google Cloud Console, no necesita este valor).
  static String? get googleOAuthClientIdIos =>
      _googleOAuthClientIdIos.isEmpty ? null : _googleOAuthClientIdIos;

  /// Client ID "Web" — da consistencia de audiencia entre plataformas.
  static String? get googleOAuthServerClientId =>
      _googleOAuthServerClientId.isEmpty ? null : _googleOAuthServerClientId;
}

import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/env.dart';

/// Envoltorio delgado sobre `GoogleSignIn.instance`: se asegura de
/// inicializar una sola vez y siempre pide únicamente el scope
/// `gmail.readonly` (sección 2 de CLAUDE.md — nunca `gmail.modify` ni
/// `gmail.send`).
class GoogleSignInService {
  static const scopes = <String>['https://www.googleapis.com/auth/gmail.readonly'];

  bool _initialized = false;

  Future<GoogleSignIn> _instance() async {
    final signIn = GoogleSignIn.instance;
    if (!_initialized) {
      await signIn.initialize(
        clientId: Env.googleOAuthClientIdIos,
        serverClientId: Env.googleOAuthServerClientId,
      );
      _initialized = true;
    }
    return signIn;
  }

  Future<({GoogleSignInAccount account, String accessToken})>
  signInAndAuthorize() async {
    final signIn = await _instance();
    final account = await signIn.authenticate();
    final authorization = await account.authorizationClient.authorizeScopes(
      scopes,
    );
    return (account: account, accessToken: authorization.accessToken);
  }

  Future<void> disconnect() async {
    final signIn = await _instance();
    await signIn.disconnect();
  }

  /// Renueva el access token sin mostrar ningún diálogo — necesario
  /// para sincronizar después de que expire (~1h) sin pedirle al
  /// usuario que vuelva a conectar Gmail. Devuelve `null` si la sesión
  /// nativa ya no es válida (hay que reconectar manualmente).
  Future<String?> renovarTokenSilenciosamente() async {
    final signIn = await _instance();
    final futuroIntento = signIn.attemptLightweightAuthentication();
    if (futuroIntento == null) return null;
    final cuenta = await futuroIntento;
    if (cuenta == null) return null;
    final autorizacion = await cuenta.authorizationClient.authorizationForScopes(
      scopes,
    );
    return autorizacion?.accessToken;
  }
}

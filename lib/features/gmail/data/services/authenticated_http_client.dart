import 'package:http/http.dart' as http;

/// Adjunta el access token de Gmail a cada request — usado solo para la
/// llamada puntual a `users.getProfile` que confirma la conexión; el
/// fetch real de correos llega en la Fase 5.
class AuthenticatedHttpClient extends http.BaseClient {
  AuthenticatedHttpClient(this._accessToken) : _inner = http.Client();

  final String _accessToken;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}

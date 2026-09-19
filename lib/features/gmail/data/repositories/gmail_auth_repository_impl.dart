import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

import '../../domain/entities/gmail_connection.dart';
import '../../domain/repositories/gmail_auth_repository.dart';
import '../datasources/gmail_auth_secure_data_source.dart';
import '../services/authenticated_http_client.dart';
import '../services/google_sign_in_service.dart';

class GmailAuthRepositoryImpl implements GmailAuthRepository {
  GmailAuthRepositoryImpl(this._dataSource, this._signInService);

  final GmailAuthSecureDataSource _dataSource;
  final GoogleSignInService _signInService;

  @override
  Future<GmailConnection?> currentConnection() => _dataSource.read();

  @override
  Future<GmailConnection> connect() async {
    final result = await _signInService.signInAndAuthorize();
    final client = AuthenticatedHttpClient(result.accessToken);
    try {
      // Llamada de humo: confirma que el scope readonly realmente quedó
      // otorgado antes de dar la conexión por buena.
      final profile = await gmail.GmailApi(client).users.getProfile('me');
      final connection = GmailConnection(
        email: profile.emailAddress ?? result.account.email,
        accessToken: result.accessToken,
        // Google no expone la expiración exacta en el cliente móvil; el
        // token real dura ~1h, dejamos margen — `obtenerConexionValida`
        // lo renueva en silencio si ya venció.
        accessTokenExpiry: DateTime.now().add(const Duration(minutes: 55)),
      );
      await _dataSource.save(connection);
      return connection;
    } finally {
      client.close();
    }
  }

  @override
  Future<void> disconnect() async {
    await _signInService.disconnect();
    await _dataSource.clear();
  }

  @override
  Future<GmailConnection?> obtenerConexionValida() async {
    final actual = await _dataSource.read();
    if (actual == null) return null;
    if (!actual.isExpired) return actual;

    String? nuevoToken;
    try {
      nuevoToken = await _signInService.renovarTokenSilenciosamente();
    } on GoogleSignInException {
      // La sesión nativa ya no es válida (cuenta desconectada, config
      // inválida, etc.) — se trata igual que "no se pudo renovar": el
      // usuario reconecta manualmente, no debe reventar la
      // sincronización con una excepción sin capturar.
      nuevoToken = null;
    }
    if (nuevoToken == null) return null;

    final renovada = GmailConnection(
      email: actual.email,
      accessToken: nuevoToken,
      accessTokenExpiry: DateTime.now().add(const Duration(minutes: 55)),
    );
    await _dataSource.save(renovada);
    return renovada;
  }
}

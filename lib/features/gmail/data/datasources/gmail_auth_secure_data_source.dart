import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/gmail_connection.dart';

/// Persistencia del token de Gmail en Keychain/Keystore — nunca en la
/// base de datos SQLite ni en `SharedPreferences` (sección 2 de
/// CLAUDE.md).
class GmailAuthSecureDataSource {
  GmailAuthSecureDataSource(this._storage);

  final FlutterSecureStorage _storage;

  static const _keyEmail = 'gmail_connected_email';
  static const _keyAccessToken = 'gmail_access_token';
  static const _keyExpiry = 'gmail_access_token_expiry';

  Future<GmailConnection?> read() async {
    final email = await _storage.read(key: _keyEmail);
    final token = await _storage.read(key: _keyAccessToken);
    final expiryRaw = await _storage.read(key: _keyExpiry);
    if (email == null || token == null || expiryRaw == null) return null;
    return GmailConnection(
      email: email,
      accessToken: token,
      accessTokenExpiry: DateTime.parse(expiryRaw),
    );
  }

  Future<void> save(GmailConnection connection) async {
    await _storage.write(key: _keyEmail, value: connection.email);
    await _storage.write(key: _keyAccessToken, value: connection.accessToken);
    await _storage.write(
      key: _keyExpiry,
      value: connection.accessTokenExpiry.toIso8601String(),
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyExpiry);
  }
}

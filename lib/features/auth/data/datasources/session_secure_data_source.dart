import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Marca si la sesión sigue activa entre arranques de la app — vive en
/// Keychain/Keystore, nunca en `SharedPreferences` (sección 2 de
/// CLAUDE.md). No es una credencial ni protege datos por sí sola (la
/// base de datos ya está cifrada con una clave independiente en
/// `flutter_secure_storage`, sección 2) — solo dice "ya se autenticó
/// esta cuenta, no vuelvas a pedir la contraseña hasta que cierre
/// sesión".
class SessionSecureDataSource {
  SessionSecureDataSource(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'session_active';

  Future<bool> activa() async => (await _storage.read(key: _key)) == 'true';

  Future<void> activar() => _storage.write(key: _key, value: 'true');

  Future<void> cerrar() => _storage.delete(key: _key);
}

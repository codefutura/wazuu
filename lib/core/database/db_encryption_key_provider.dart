import 'dart:convert';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/secure_storage_provider.dart';

part 'db_encryption_key_provider.g.dart';

const _keyDbPassphrase = 'db_encryption_key';

/// Clave de cifrado de la base de datos SQLite (sqlcipher).
///
/// Se genera una sola vez por instalación y se guarda en Keychain/
/// Keystore — nunca en la propia base de datos ni en `SharedPreferences`.
/// Es independiente de la contraseña de login: vive en el dispositivo,
/// no en la cabeza del usuario, para no perder los datos si la olvida.
@Riverpod(keepAlive: true)
Future<String> dbEncryptionKey(Ref ref) async {
  final storage = ref.watch(secureStorageProvider);
  final existing = await storage.read(key: _keyDbPassphrase);
  if (existing != null) return existing;

  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  final passphrase = base64UrlEncode(bytes);
  await storage.write(key: _keyDbPassphrase, value: passphrase);
  return passphrase;
}

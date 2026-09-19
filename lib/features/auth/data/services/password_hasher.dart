import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Hash SHA-256 con sal aleatoria por cuenta (mismo patrón usado en
/// FuturaCobros). La sal se guarda junto al hash — nunca la contraseña
/// en texto plano.
class PasswordHasher {
  const PasswordHasher();

  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  String hash({required String password, required String salt}) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }
}

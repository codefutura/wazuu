// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_encryption_key_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Clave de cifrado de la base de datos SQLite (sqlcipher).
///
/// Se genera una sola vez por instalación y se guarda en Keychain/
/// Keystore — nunca en la propia base de datos ni en `SharedPreferences`.
/// Es independiente de la contraseña de login: vive en el dispositivo,
/// no en la cabeza del usuario, para no perder los datos si la olvida.

@ProviderFor(dbEncryptionKey)
final dbEncryptionKeyProvider = DbEncryptionKeyProvider._();

/// Clave de cifrado de la base de datos SQLite (sqlcipher).
///
/// Se genera una sola vez por instalación y se guarda en Keychain/
/// Keystore — nunca en la propia base de datos ni en `SharedPreferences`.
/// Es independiente de la contraseña de login: vive en el dispositivo,
/// no en la cabeza del usuario, para no perder los datos si la olvida.

final class DbEncryptionKeyProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Clave de cifrado de la base de datos SQLite (sqlcipher).
  ///
  /// Se genera una sola vez por instalación y se guarda en Keychain/
  /// Keystore — nunca en la propia base de datos ni en `SharedPreferences`.
  /// Es independiente de la contraseña de login: vive en el dispositivo,
  /// no en la cabeza del usuario, para no perder los datos si la olvida.
  DbEncryptionKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dbEncryptionKeyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dbEncryptionKeyHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return dbEncryptionKey(ref);
  }
}

String _$dbEncryptionKeyHash() => r'5e8d1f93a5644e93c0e4e47df86a4890a739d401';

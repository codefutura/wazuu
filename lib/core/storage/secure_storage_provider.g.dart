// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Instancia única de `flutter_secure_storage`, compartida por cualquier
/// feature que necesite guardar datos sensibles en Keychain/Keystore
/// (cuenta local hoy, tokens OAuth de Gmail en la Fase 4).

@ProviderFor(secureStorage)
final secureStorageProvider = SecureStorageProvider._();

/// Instancia única de `flutter_secure_storage`, compartida por cualquier
/// feature que necesite guardar datos sensibles en Keychain/Keystore
/// (cuenta local hoy, tokens OAuth de Gmail en la Fase 4).

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  /// Instancia única de `flutter_secure_storage`, compartida por cualquier
  /// feature que necesite guardar datos sensibles en Keychain/Keystore
  /// (cuenta local hoy, tokens OAuth de Gmail en la Fase 4).
  SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'0cd1b80f91784467390034386f925a0be155bfbd';

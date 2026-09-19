import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_provider.g.dart';

/// Instancia única de `flutter_secure_storage`, compartida por cualquier
/// feature que necesite guardar datos sensibles en Keychain/Keystore
/// (cuenta local hoy, tokens OAuth de Gmail en la Fase 4).
@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) => const FlutterSecureStorage();

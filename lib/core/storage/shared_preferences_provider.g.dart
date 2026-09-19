// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Instancia única de `SharedPreferences`.
///
/// Interino: guarda hoy el progreso del onboarding (datos no sensibles).
/// La Fase 3 mueve ese progreso a SQLite y este provider queda disponible
/// para preferencias de UI no sensibles (ej. tema forzado en Ajustes).

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Instancia única de `SharedPreferences`.
///
/// Interino: guarda hoy el progreso del onboarding (datos no sensibles).
/// La Fase 3 mueve ese progreso a SQLite y este provider queda disponible
/// para preferencias de UI no sensibles (ej. tema forzado en Ajustes).

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// Instancia única de `SharedPreferences`.
  ///
  /// Interino: guarda hoy el progreso del onboarding (datos no sensibles).
  /// La Fase 3 mueve ese progreso a SQLite y este provider queda disponible
  /// para preferencias de UI no sensibles (ej. tema forzado en Ajustes).
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'ad13470fe866595ad0f58a3e26f11048d94ef22e';

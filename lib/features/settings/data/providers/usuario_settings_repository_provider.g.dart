// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_settings_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(usuarioSettingsRepository)
final usuarioSettingsRepositoryProvider = UsuarioSettingsRepositoryProvider._();

final class UsuarioSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<UsuarioSettingsRepository>,
          UsuarioSettingsRepository,
          FutureOr<UsuarioSettingsRepository>
        >
    with
        $FutureModifier<UsuarioSettingsRepository>,
        $FutureProvider<UsuarioSettingsRepository> {
  UsuarioSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usuarioSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usuarioSettingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<UsuarioSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UsuarioSettingsRepository> create(Ref ref) {
    return usuarioSettingsRepository(ref);
  }
}

String _$usuarioSettingsRepositoryHash() =>
    r'552c5fa2dd1231cb5c7b4faca8bff0d0a638f859';

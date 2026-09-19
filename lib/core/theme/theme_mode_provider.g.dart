// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `ThemeMode.system` por defecto; el usuario puede forzarlo desde
/// Ajustes (sección 3 de CLAUDE.md).

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// `ThemeMode.system` por defecto; el usuario puede forzarlo desde
/// Ajustes (sección 3 de CLAUDE.md).
final class ThemeModeControllerProvider
    extends $AsyncNotifierProvider<ThemeModeController, ThemeMode> {
  /// `ThemeMode.system` por defecto; el usuario puede forzarlo desde
  /// Ajustes (sección 3 de CLAUDE.md).
  ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();
}

String _$themeModeControllerHash() =>
    r'bbc0a3da5348b78780c1486e2e0df0ea587c54a5';

/// `ThemeMode.system` por defecto; el usuario puede forzarlo desde
/// Ajustes (sección 3 de CLAUDE.md).

abstract class _$ThemeModeController extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
              AsyncValue<ThemeMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

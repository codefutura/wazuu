// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_seleccionado_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pestaña activa de `MainShellScreen` — vive en un provider (no en
/// `State` local) para que otras pantallas puedan saltar a una
/// pestaña específica, ej. tocar una tarjeta salta a Transacciones ya
/// filtrada por esa tarjeta.

@ProviderFor(TabSeleccionadoController)
final tabSeleccionadoControllerProvider = TabSeleccionadoControllerProvider._();

/// Pestaña activa de `MainShellScreen` — vive en un provider (no en
/// `State` local) para que otras pantallas puedan saltar a una
/// pestaña específica, ej. tocar una tarjeta salta a Transacciones ya
/// filtrada por esa tarjeta.
final class TabSeleccionadoControllerProvider
    extends $NotifierProvider<TabSeleccionadoController, int> {
  /// Pestaña activa de `MainShellScreen` — vive en un provider (no en
  /// `State` local) para que otras pantallas puedan saltar a una
  /// pestaña específica, ej. tocar una tarjeta salta a Transacciones ya
  /// filtrada por esa tarjeta.
  TabSeleccionadoControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabSeleccionadoControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabSeleccionadoControllerHash();

  @$internal
  @override
  TabSeleccionadoController create() => TabSeleccionadoController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$tabSeleccionadoControllerHash() =>
    r'9d1304f900d5f5eb522cdfeffc262a4346431514';

/// Pestaña activa de `MainShellScreen` — vive en un provider (no en
/// `State` local) para que otras pantallas puedan saltar a una
/// pestaña específica, ej. tocar una tarjeta salta a Transacciones ya
/// filtrada por esa tarjeta.

abstract class _$TabSeleccionadoController extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

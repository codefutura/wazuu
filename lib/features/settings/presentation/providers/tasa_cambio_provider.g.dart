// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasa_cambio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tasa de cambio manual (sección 9.6 de CLAUDE.md). Al cambiarla,
/// invalida los resúmenes que la usan para consolidar DOP/USD — si no,
/// seguirían mostrando el estado "sin tasa configurada" hasta que algo
/// más los recalculara.

@ProviderFor(TasaCambioController)
final tasaCambioControllerProvider = TasaCambioControllerProvider._();

/// Tasa de cambio manual (sección 9.6 de CLAUDE.md). Al cambiarla,
/// invalida los resúmenes que la usan para consolidar DOP/USD — si no,
/// seguirían mostrando el estado "sin tasa configurada" hasta que algo
/// más los recalculara.
final class TasaCambioControllerProvider
    extends $AsyncNotifierProvider<TasaCambioController, double?> {
  /// Tasa de cambio manual (sección 9.6 de CLAUDE.md). Al cambiarla,
  /// invalida los resúmenes que la usan para consolidar DOP/USD — si no,
  /// seguirían mostrando el estado "sin tasa configurada" hasta que algo
  /// más los recalculara.
  TasaCambioControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasaCambioControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasaCambioControllerHash();

  @$internal
  @override
  TasaCambioController create() => TasaCambioController();
}

String _$tasaCambioControllerHash() =>
    r'488a765ba08951617a21b351a4a612e3c07fa8a8';

/// Tasa de cambio manual (sección 9.6 de CLAUDE.md). Al cambiarla,
/// invalida los resúmenes que la usan para consolidar DOP/USD — si no,
/// seguirían mostrando el estado "sin tasa configurada" hasta que algo
/// más los recalculara.

abstract class _$TasaCambioController extends $AsyncNotifier<double?> {
  FutureOr<double?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<double?>, double?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<double?>, double?>,
              AsyncValue<double?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

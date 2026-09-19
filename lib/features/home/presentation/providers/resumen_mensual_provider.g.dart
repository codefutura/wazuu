// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resumen_mensual_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Rango de la gráfica de tendencia en la pantalla de inicio —
/// controlable por el usuario (sección 9.2 de CLAUDE.md: "se requiere
/// poder manipular los filtros" de la gráfica).

@ProviderFor(RangoTendenciaController)
final rangoTendenciaControllerProvider = RangoTendenciaControllerProvider._();

/// Rango de la gráfica de tendencia en la pantalla de inicio —
/// controlable por el usuario (sección 9.2 de CLAUDE.md: "se requiere
/// poder manipular los filtros" de la gráfica).
final class RangoTendenciaControllerProvider
    extends $NotifierProvider<RangoTendenciaController, int> {
  /// Rango de la gráfica de tendencia en la pantalla de inicio —
  /// controlable por el usuario (sección 9.2 de CLAUDE.md: "se requiere
  /// poder manipular los filtros" de la gráfica).
  RangoTendenciaControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rangoTendenciaControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rangoTendenciaControllerHash();

  @$internal
  @override
  RangoTendenciaController create() => RangoTendenciaController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$rangoTendenciaControllerHash() =>
    r'b5e223a7d4c37753889176cb14c496660ee9153e';

/// Rango de la gráfica de tendencia en la pantalla de inicio —
/// controlable por el usuario (sección 9.2 de CLAUDE.md: "se requiere
/// poder manipular los filtros" de la gráfica).

abstract class _$RangoTendenciaController extends $Notifier<int> {
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

@ProviderFor(resumenMensual)
final resumenMensualProvider = ResumenMensualProvider._();

final class ResumenMensualProvider
    extends
        $FunctionalProvider<
          AsyncValue<ResumenMensualData>,
          ResumenMensualData,
          FutureOr<ResumenMensualData>
        >
    with
        $FutureModifier<ResumenMensualData>,
        $FutureProvider<ResumenMensualData> {
  ResumenMensualProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resumenMensualProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resumenMensualHash();

  @$internal
  @override
  $FutureProviderElement<ResumenMensualData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ResumenMensualData> create(Ref ref) {
    return resumenMensual(ref);
  }
}

String _$resumenMensualHash() => r'5d042e07562b577b2b08b58a96ea60fce9a5d6fb';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transacciones_filtro_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Estado de los filtros de la lista de transacciones (sección 9.4 de
/// CLAUDE.md — filtrable por fecha, categoría, tarjeta).
///
/// `keepAlive: true`: otras pantallas (ej. tocar una tarjeta) cambian
/// este filtro sin que la pantalla de Transacciones esté montada para
/// "escucharlo" — sin esto, Riverpod lo descarta (autoDispose, sin
/// listeners activos) antes de que Transacciones llegue a leerlo.

@ProviderFor(TransaccionesFiltroController)
final transaccionesFiltroControllerProvider =
    TransaccionesFiltroControllerProvider._();

/// Estado de los filtros de la lista de transacciones (sección 9.4 de
/// CLAUDE.md — filtrable por fecha, categoría, tarjeta).
///
/// `keepAlive: true`: otras pantallas (ej. tocar una tarjeta) cambian
/// este filtro sin que la pantalla de Transacciones esté montada para
/// "escucharlo" — sin esto, Riverpod lo descarta (autoDispose, sin
/// listeners activos) antes de que Transacciones llegue a leerlo.
final class TransaccionesFiltroControllerProvider
    extends
        $NotifierProvider<TransaccionesFiltroController, TransaccionesFiltro> {
  /// Estado de los filtros de la lista de transacciones (sección 9.4 de
  /// CLAUDE.md — filtrable por fecha, categoría, tarjeta).
  ///
  /// `keepAlive: true`: otras pantallas (ej. tocar una tarjeta) cambian
  /// este filtro sin que la pantalla de Transacciones esté montada para
  /// "escucharlo" — sin esto, Riverpod lo descarta (autoDispose, sin
  /// listeners activos) antes de que Transacciones llegue a leerlo.
  TransaccionesFiltroControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transaccionesFiltroControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transaccionesFiltroControllerHash();

  @$internal
  @override
  TransaccionesFiltroController create() => TransaccionesFiltroController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransaccionesFiltro value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransaccionesFiltro>(value),
    );
  }
}

String _$transaccionesFiltroControllerHash() =>
    r'cd8112893e8f8ee097de20ed5d7b4915cc997c50';

/// Estado de los filtros de la lista de transacciones (sección 9.4 de
/// CLAUDE.md — filtrable por fecha, categoría, tarjeta).
///
/// `keepAlive: true`: otras pantallas (ej. tocar una tarjeta) cambian
/// este filtro sin que la pantalla de Transacciones esté montada para
/// "escucharlo" — sin esto, Riverpod lo descarta (autoDispose, sin
/// listeners activos) antes de que Transacciones llegue a leerlo.

abstract class _$TransaccionesFiltroController
    extends $Notifier<TransaccionesFiltro> {
  TransaccionesFiltro build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TransaccionesFiltro, TransaccionesFiltro>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransaccionesFiltro, TransaccionesFiltro>,
              TransaccionesFiltro,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(transaccionesFiltradas)
final transaccionesFiltradasProvider = TransaccionesFiltradasProvider._();

final class TransaccionesFiltradasProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransaccionRegistro>>,
          List<TransaccionRegistro>,
          FutureOr<List<TransaccionRegistro>>
        >
    with
        $FutureModifier<List<TransaccionRegistro>>,
        $FutureProvider<List<TransaccionRegistro>> {
  TransaccionesFiltradasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transaccionesFiltradasProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transaccionesFiltradasHash();

  @$internal
  @override
  $FutureProviderElement<List<TransaccionRegistro>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TransaccionRegistro>> create(Ref ref) {
    return transaccionesFiltradas(ref);
  }
}

String _$transaccionesFiltradasHash() =>
    r'b7b7e136e50eda0290ea505d7a7e093ae0858e1f';

@ProviderFor(tarjetasDisponibles)
final tarjetasDisponiblesProvider = TarjetasDisponiblesProvider._();

final class TarjetasDisponiblesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tarjeta>>,
          List<Tarjeta>,
          FutureOr<List<Tarjeta>>
        >
    with $FutureModifier<List<Tarjeta>>, $FutureProvider<List<Tarjeta>> {
  TarjetasDisponiblesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tarjetasDisponiblesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tarjetasDisponiblesHash();

  @$internal
  @override
  $FutureProviderElement<List<Tarjeta>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Tarjeta>> create(Ref ref) {
    return tarjetasDisponibles(ref);
  }
}

String _$tarjetasDisponiblesHash() =>
    r'a4237438dc7003919c77afd419a59471cc607f4a';

/// Solo las categorías de gasto (sección 8 de CLAUDE.md) — el filtro
/// de la lista de transacciones no ofrece las de ingreso (Nómina,
/// Transferencia, Otro ingreso) como opción.

@ProviderFor(categoriasGasto)
final categoriasGastoProvider = CategoriasGastoProvider._();

/// Solo las categorías de gasto (sección 8 de CLAUDE.md) — el filtro
/// de la lista de transacciones no ofrece las de ingreso (Nómina,
/// Transferencia, Otro ingreso) como opción.

final class CategoriasGastoProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Categoria>>,
          List<Categoria>,
          FutureOr<List<Categoria>>
        >
    with $FutureModifier<List<Categoria>>, $FutureProvider<List<Categoria>> {
  /// Solo las categorías de gasto (sección 8 de CLAUDE.md) — el filtro
  /// de la lista de transacciones no ofrece las de ingreso (Nómina,
  /// Transferencia, Otro ingreso) como opción.
  CategoriasGastoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriasGastoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriasGastoHash();

  @$internal
  @override
  $FutureProviderElement<List<Categoria>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Categoria>> create(Ref ref) {
    return categoriasGasto(ref);
  }
}

String _$categoriasGastoHash() => r'bb78c7c51467f5ad664c61c347492ce7cf33d822';

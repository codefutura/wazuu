// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lista_tarjetas_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lista simple de tarjetas — usada por Ajustes para gestionarlas
/// (crear/editar/eliminar), sin el cálculo de consumo que trae
/// `tarjetasConsumoProvider`.

@ProviderFor(listaTarjetas)
final listaTarjetasProvider = ListaTarjetasProvider._();

/// Lista simple de tarjetas — usada por Ajustes para gestionarlas
/// (crear/editar/eliminar), sin el cálculo de consumo que trae
/// `tarjetasConsumoProvider`.

final class ListaTarjetasProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tarjeta>>,
          List<Tarjeta>,
          FutureOr<List<Tarjeta>>
        >
    with $FutureModifier<List<Tarjeta>>, $FutureProvider<List<Tarjeta>> {
  /// Lista simple de tarjetas — usada por Ajustes para gestionarlas
  /// (crear/editar/eliminar), sin el cálculo de consumo que trae
  /// `tarjetasConsumoProvider`.
  ListaTarjetasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listaTarjetasProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listaTarjetasHash();

  @$internal
  @override
  $FutureProviderElement<List<Tarjeta>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Tarjeta>> create(Ref ref) {
    return listaTarjetas(ref);
  }
}

String _$listaTarjetasHash() => r'ced2c61d973770fe4354096010dbcc6d2e777ca4';

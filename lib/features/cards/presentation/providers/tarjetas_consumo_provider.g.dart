// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarjetas_consumo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tarjetasConsumo)
final tarjetasConsumoProvider = TarjetasConsumoProvider._();

final class TarjetasConsumoProvider
    extends
        $FunctionalProvider<
          AsyncValue<TarjetasConsumoData>,
          TarjetasConsumoData,
          FutureOr<TarjetasConsumoData>
        >
    with
        $FutureModifier<TarjetasConsumoData>,
        $FutureProvider<TarjetasConsumoData> {
  TarjetasConsumoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tarjetasConsumoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tarjetasConsumoHash();

  @$internal
  @override
  $FutureProviderElement<TarjetasConsumoData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TarjetasConsumoData> create(Ref ref) {
    return tarjetasConsumo(ref);
  }
}

String _$tarjetasConsumoHash() => r'61ec9353538d43bcacb388740c983114bfd7137d';

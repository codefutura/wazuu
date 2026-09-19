// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarjetas_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tarjetasRepository)
final tarjetasRepositoryProvider = TarjetasRepositoryProvider._();

final class TarjetasRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<TarjetasRepository>,
          TarjetasRepository,
          FutureOr<TarjetasRepository>
        >
    with
        $FutureModifier<TarjetasRepository>,
        $FutureProvider<TarjetasRepository> {
  TarjetasRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tarjetasRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tarjetasRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<TarjetasRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TarjetasRepository> create(Ref ref) {
    return tarjetasRepository(ref);
  }
}

String _$tarjetasRepositoryHash() =>
    r'62416520592118ca9ffa7b548e0d04aac2c3fbe6';

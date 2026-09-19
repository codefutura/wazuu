// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transacciones_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transaccionesRepository)
final transaccionesRepositoryProvider = TransaccionesRepositoryProvider._();

final class TransaccionesRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<TransaccionesRepository>,
          TransaccionesRepository,
          FutureOr<TransaccionesRepository>
        >
    with
        $FutureModifier<TransaccionesRepository>,
        $FutureProvider<TransaccionesRepository> {
  TransaccionesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transaccionesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transaccionesRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<TransaccionesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TransaccionesRepository> create(Ref ref) {
    return transaccionesRepository(ref);
  }
}

String _$transaccionesRepositoryHash() =>
    r'b0c963992b41a7972108022f8933b192a342b954';

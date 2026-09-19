// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presupuestos_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(presupuestosRepository)
final presupuestosRepositoryProvider = PresupuestosRepositoryProvider._();

final class PresupuestosRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PresupuestosRepository>,
          PresupuestosRepository,
          FutureOr<PresupuestosRepository>
        >
    with
        $FutureModifier<PresupuestosRepository>,
        $FutureProvider<PresupuestosRepository> {
  PresupuestosRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presupuestosRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presupuestosRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<PresupuestosRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PresupuestosRepository> create(Ref ref) {
    return presupuestosRepository(ref);
  }
}

String _$presupuestosRepositoryHash() =>
    r'191ff4f32de80f77680bac865c65db43e1a32b49';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorization_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoriasRepository)
final categoriasRepositoryProvider = CategoriasRepositoryProvider._();

final class CategoriasRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<CategoriasRepository>,
          CategoriasRepository,
          FutureOr<CategoriasRepository>
        >
    with
        $FutureModifier<CategoriasRepository>,
        $FutureProvider<CategoriasRepository> {
  CategoriasRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriasRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriasRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<CategoriasRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CategoriasRepository> create(Ref ref) {
    return categoriasRepository(ref);
  }
}

String _$categoriasRepositoryHash() =>
    r'883c399bc9d38ced93674a22bc4eaf753f715eae';

@ProviderFor(reglasCategorizacionRepository)
final reglasCategorizacionRepositoryProvider =
    ReglasCategorizacionRepositoryProvider._();

final class ReglasCategorizacionRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReglasCategorizacionRepository>,
          ReglasCategorizacionRepository,
          FutureOr<ReglasCategorizacionRepository>
        >
    with
        $FutureModifier<ReglasCategorizacionRepository>,
        $FutureProvider<ReglasCategorizacionRepository> {
  ReglasCategorizacionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reglasCategorizacionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reglasCategorizacionRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ReglasCategorizacionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReglasCategorizacionRepository> create(Ref ref) {
    return reglasCategorizacionRepository(ref);
  }
}

String _$reglasCategorizacionRepositoryHash() =>
    r'a11ed52fd4def14c0d514d8a55265869b7d977fa';

/// Lista completa de categorías — usada por filtros y formularios en
/// otras features (transacciones, presupuestos) que solo necesitan
/// mostrarlas, no categorizar nada.

@ProviderFor(todasLasCategorias)
final todasLasCategoriasProvider = TodasLasCategoriasProvider._();

/// Lista completa de categorías — usada por filtros y formularios en
/// otras features (transacciones, presupuestos) que solo necesitan
/// mostrarlas, no categorizar nada.

final class TodasLasCategoriasProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Categoria>>,
          List<Categoria>,
          FutureOr<List<Categoria>>
        >
    with $FutureModifier<List<Categoria>>, $FutureProvider<List<Categoria>> {
  /// Lista completa de categorías — usada por filtros y formularios en
  /// otras features (transacciones, presupuestos) que solo necesitan
  /// mostrarlas, no categorizar nada.
  TodasLasCategoriasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todasLasCategoriasProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todasLasCategoriasHash();

  @$internal
  @override
  $FutureProviderElement<List<Categoria>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Categoria>> create(Ref ref) {
    return todasLasCategorias(ref);
  }
}

String _$todasLasCategoriasHash() =>
    r'5cc4e63ef4232a4c6097f008e6222d38772100b5';

@ProviderFor(categorizationEngine)
final categorizationEngineProvider = CategorizationEngineProvider._();

final class CategorizationEngineProvider
    extends
        $FunctionalProvider<
          AsyncValue<CategorizationEngine>,
          CategorizationEngine,
          FutureOr<CategorizationEngine>
        >
    with
        $FutureModifier<CategorizationEngine>,
        $FutureProvider<CategorizationEngine> {
  CategorizationEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categorizationEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categorizationEngineHash();

  @$internal
  @override
  $FutureProviderElement<CategorizationEngine> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CategorizationEngine> create(Ref ref) {
    return categorizationEngine(ref);
  }
}

String _$categorizationEngineHash() =>
    r'f14829a5acf5ed048b3578fc038697000e89003f';

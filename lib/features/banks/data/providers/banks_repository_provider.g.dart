// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banks_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(banksRepository)
final banksRepositoryProvider = BanksRepositoryProvider._();

final class BanksRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<BanksRepository>,
          BanksRepository,
          FutureOr<BanksRepository>
        >
    with $FutureModifier<BanksRepository>, $FutureProvider<BanksRepository> {
  BanksRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'banksRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$banksRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<BanksRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BanksRepository> create(Ref ref) {
    return banksRepository(ref);
  }
}

String _$banksRepositoryHash() => r'4a6de7c40bfd3818415a982ada5799a671373489';

/// Bancos conectados reales (con `id` de base de datos) — usado por el
/// selector de banco al crear una tarjeta.

@ProviderFor(bancosConectados)
final bancosConectadosProvider = BancosConectadosProvider._();

/// Bancos conectados reales (con `id` de base de datos) — usado por el
/// selector de banco al crear una tarjeta.

final class BancosConectadosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BancoConectado>>,
          List<BancoConectado>,
          FutureOr<List<BancoConectado>>
        >
    with
        $FutureModifier<List<BancoConectado>>,
        $FutureProvider<List<BancoConectado>> {
  /// Bancos conectados reales (con `id` de base de datos) — usado por el
  /// selector de banco al crear una tarjeta.
  BancosConectadosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bancosConectadosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bancosConectadosHash();

  @$internal
  @override
  $FutureProviderElement<List<BancoConectado>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BancoConectado>> create(Ref ref) {
    return bancosConectados(ref);
  }
}

String _$bancosConectadosHash() => r'426cc05e241132988aa590e35738730e63b6fdcf';

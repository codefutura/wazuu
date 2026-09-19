// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bcrd_exchange_rate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bcrdExchangeRateDataSource)
final bcrdExchangeRateDataSourceProvider =
    BcrdExchangeRateDataSourceProvider._();

final class BcrdExchangeRateDataSourceProvider
    extends
        $FunctionalProvider<
          BcrdExchangeRateDataSource,
          BcrdExchangeRateDataSource,
          BcrdExchangeRateDataSource
        >
    with $Provider<BcrdExchangeRateDataSource> {
  BcrdExchangeRateDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bcrdExchangeRateDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bcrdExchangeRateDataSourceHash();

  @$internal
  @override
  $ProviderElement<BcrdExchangeRateDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BcrdExchangeRateDataSource create(Ref ref) {
    return bcrdExchangeRateDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BcrdExchangeRateDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BcrdExchangeRateDataSource>(value),
    );
  }
}

String _$bcrdExchangeRateDataSourceHash() =>
    r'2ba7bc6ef3f55d7beb5cef2f13b33ca7619baa29';

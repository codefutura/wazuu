// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gmailMessagesFetcher)
final gmailMessagesFetcherProvider = GmailMessagesFetcherProvider._();

final class GmailMessagesFetcherProvider
    extends
        $FunctionalProvider<
          GmailMessagesFetcher,
          GmailMessagesFetcher,
          GmailMessagesFetcher
        >
    with $Provider<GmailMessagesFetcher> {
  GmailMessagesFetcherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gmailMessagesFetcherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gmailMessagesFetcherHash();

  @$internal
  @override
  $ProviderElement<GmailMessagesFetcher> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GmailMessagesFetcher create(Ref ref) {
    return gmailMessagesFetcher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GmailMessagesFetcher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GmailMessagesFetcher>(value),
    );
  }
}

String _$gmailMessagesFetcherHash() =>
    r'63bc4830690b829bd8179d8ffd631ae13c5f7060';

@ProviderFor(syncStateRepository)
final syncStateRepositoryProvider = SyncStateRepositoryProvider._();

final class SyncStateRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncStateRepository>,
          SyncStateRepository,
          FutureOr<SyncStateRepository>
        >
    with
        $FutureModifier<SyncStateRepository>,
        $FutureProvider<SyncStateRepository> {
  SyncStateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStateRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStateRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SyncStateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SyncStateRepository> create(Ref ref) {
    return syncStateRepository(ref);
  }
}

String _$syncStateRepositoryHash() =>
    r'612d2a7a9bfa3b45406fff9992fb80cf25dddd8e';

@ProviderFor(gmailSyncService)
final gmailSyncServiceProvider = GmailSyncServiceProvider._();

final class GmailSyncServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<GmailSyncService>,
          GmailSyncService,
          FutureOr<GmailSyncService>
        >
    with $FutureModifier<GmailSyncService>, $FutureProvider<GmailSyncService> {
  GmailSyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gmailSyncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gmailSyncServiceHash();

  @$internal
  @override
  $FutureProviderElement<GmailSyncService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GmailSyncService> create(Ref ref) {
    return gmailSyncService(ref);
  }
}

String _$gmailSyncServiceHash() => r'ad90fc98473356188a1d3ea92176eaea168bb2b9';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmail_auth_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gmailAuthRepository)
final gmailAuthRepositoryProvider = GmailAuthRepositoryProvider._();

final class GmailAuthRepositoryProvider
    extends
        $FunctionalProvider<
          GmailAuthRepository,
          GmailAuthRepository,
          GmailAuthRepository
        >
    with $Provider<GmailAuthRepository> {
  GmailAuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gmailAuthRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gmailAuthRepositoryHash();

  @$internal
  @override
  $ProviderElement<GmailAuthRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GmailAuthRepository create(Ref ref) {
    return gmailAuthRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GmailAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GmailAuthRepository>(value),
    );
  }
}

String _$gmailAuthRepositoryHash() =>
    r'552745b450ef6abb8456b54846eff47a11adc11b';

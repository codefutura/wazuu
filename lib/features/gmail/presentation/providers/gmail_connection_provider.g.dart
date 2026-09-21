// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmail_connection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Conexión de Gmail guardada, para mostrar el estado en Ajustes
/// (sección 9.6 de CLAUDE.md). Se invalida manualmente después de
/// conectar/desconectar — ver `GmailConnectionSection`.

@ProviderFor(gmailConnection)
final gmailConnectionProvider = GmailConnectionProvider._();

/// Conexión de Gmail guardada, para mostrar el estado en Ajustes
/// (sección 9.6 de CLAUDE.md). Se invalida manualmente después de
/// conectar/desconectar — ver `GmailConnectionSection`.

final class GmailConnectionProvider
    extends
        $FunctionalProvider<
          AsyncValue<GmailConnection?>,
          GmailConnection?,
          FutureOr<GmailConnection?>
        >
    with $FutureModifier<GmailConnection?>, $FutureProvider<GmailConnection?> {
  /// Conexión de Gmail guardada, para mostrar el estado en Ajustes
  /// (sección 9.6 de CLAUDE.md). Se invalida manualmente después de
  /// conectar/desconectar — ver `GmailConnectionSection`.
  GmailConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gmailConnectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gmailConnectionHash();

  @$internal
  @override
  $FutureProviderElement<GmailConnection?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GmailConnection?> create(Ref ref) {
    return gmailConnection(ref);
  }
}

String _$gmailConnectionHash() => r'2f75c9f9784df26f86cfded59f3eab47051b7c53';

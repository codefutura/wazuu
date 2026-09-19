// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bancos_seleccionados_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selección de bancos conectados en edición (Ajustes, sección 9.6 de
/// CLAUDE.md) — separado del guardado real para poder mostrar los
/// cambios antes de confirmarlos.

@ProviderFor(BancosSeleccionadosController)
final bancosSeleccionadosControllerProvider =
    BancosSeleccionadosControllerProvider._();

/// Selección de bancos conectados en edición (Ajustes, sección 9.6 de
/// CLAUDE.md) — separado del guardado real para poder mostrar los
/// cambios antes de confirmarlos.
final class BancosSeleccionadosControllerProvider
    extends $AsyncNotifierProvider<BancosSeleccionadosController, Set<String>> {
  /// Selección de bancos conectados en edición (Ajustes, sección 9.6 de
  /// CLAUDE.md) — separado del guardado real para poder mostrar los
  /// cambios antes de confirmarlos.
  BancosSeleccionadosControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bancosSeleccionadosControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bancosSeleccionadosControllerHash();

  @$internal
  @override
  BancosSeleccionadosController create() => BancosSeleccionadosController();
}

String _$bancosSeleccionadosControllerHash() =>
    r'8c07d7c170d9696ea6a08124593632ba927c5690';

/// Selección de bancos conectados en edición (Ajustes, sección 9.6 de
/// CLAUDE.md) — separado del guardado real para poder mostrar los
/// cambios antes de confirmarlos.

abstract class _$BancosSeleccionadosController
    extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

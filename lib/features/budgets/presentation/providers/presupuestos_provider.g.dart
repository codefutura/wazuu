// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presupuestos_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Calcula el progreso de cada presupuesto del mes actual y, de paso,
/// dispara las alertas de 80%/100% que todavía no se hayan notificado
/// (sección 9.5 de CLAUDE.md).
///
/// La revisión ocurre cuando se carga esta pantalla — no hay
/// sincronización en segundo plano todavía, así que una alerta no
/// llega instantáneamente al cruzar el umbral, sino la próxima vez que
/// se abre o refresca Presupuestos.

@ProviderFor(presupuestosConProgreso)
final presupuestosConProgresoProvider = PresupuestosConProgresoProvider._();

/// Calcula el progreso de cada presupuesto del mes actual y, de paso,
/// dispara las alertas de 80%/100% que todavía no se hayan notificado
/// (sección 9.5 de CLAUDE.md).
///
/// La revisión ocurre cuando se carga esta pantalla — no hay
/// sincronización en segundo plano todavía, así que una alerta no
/// llega instantáneamente al cruzar el umbral, sino la próxima vez que
/// se abre o refresca Presupuestos.

final class PresupuestosConProgresoProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProgresoPresupuesto>>,
          List<ProgresoPresupuesto>,
          FutureOr<List<ProgresoPresupuesto>>
        >
    with
        $FutureModifier<List<ProgresoPresupuesto>>,
        $FutureProvider<List<ProgresoPresupuesto>> {
  /// Calcula el progreso de cada presupuesto del mes actual y, de paso,
  /// dispara las alertas de 80%/100% que todavía no se hayan notificado
  /// (sección 9.5 de CLAUDE.md).
  ///
  /// La revisión ocurre cuando se carga esta pantalla — no hay
  /// sincronización en segundo plano todavía, así que una alerta no
  /// llega instantáneamente al cruzar el umbral, sino la próxima vez que
  /// se abre o refresca Presupuestos.
  PresupuestosConProgresoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presupuestosConProgresoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presupuestosConProgresoHash();

  @$internal
  @override
  $FutureProviderElement<List<ProgresoPresupuesto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProgresoPresupuesto>> create(Ref ref) {
    return presupuestosConProgreso(ref);
  }
}

String _$presupuestosConProgresoHash() =>
    r'a9a482f05459bd1fc79ac318fd3a44ed31a6b24f';

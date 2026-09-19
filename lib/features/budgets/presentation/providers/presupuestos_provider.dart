import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../categorization/data/providers/categorization_providers.dart';
import '../../../settings/data/providers/usuario_settings_repository_provider.dart';
import '../../../transactions/data/providers/transacciones_repository_provider.dart';
import '../../data/providers/budget_alert_dispatcher_provider.dart';
import '../../data/providers/presupuestos_repository_provider.dart';
import '../../domain/entities/progreso_presupuesto.dart';
import '../../domain/progreso_presupuestos_calculator.dart';

part 'presupuestos_provider.g.dart';

/// Calcula el progreso de cada presupuesto del mes actual y, de paso,
/// dispara las alertas de 80%/100% que todavía no se hayan notificado
/// (sección 9.5 de CLAUDE.md).
///
/// La revisión ocurre cuando se carga esta pantalla — no hay
/// sincronización en segundo plano todavía, así que una alerta no
/// llega instantáneamente al cruzar el umbral, sino la próxima vez que
/// se abre o refresca Presupuestos.
@riverpod
Future<List<ProgresoPresupuesto>> presupuestosConProgreso(Ref ref) async {
  final presupuestosRepo = await ref.watch(
    presupuestosRepositoryProvider.future,
  );
  final transaccionesRepo = await ref.watch(
    transaccionesRepositoryProvider.future,
  );
  final categorias = await ref.watch(todasLasCategoriasProvider.future);
  final settingsRepo = await ref.watch(
    usuarioSettingsRepositoryProvider.future,
  );

  final ahora = DateTime.now();
  final inicioMes = DateTime(ahora.year, ahora.month);

  final presupuestos = await presupuestosRepo.obtenerTodos();
  final transacciones = await transaccionesRepo.obtener(desde: inicioMes);
  final tasa = await settingsRepo.obtenerTasaCambioReferencia();

  final progresos = const ProgresoPresupuestosCalculator().calcular(
    presupuestos: presupuestos,
    transaccionesDelPeriodo: transacciones,
    categorias: categorias,
    tasaCambioReferencia: tasa,
  );

  final dispatcher = await ref.watch(budgetAlertDispatcherProvider.future);
  await dispatcher.evaluarYNotificar(progresos);

  return progresos;
}

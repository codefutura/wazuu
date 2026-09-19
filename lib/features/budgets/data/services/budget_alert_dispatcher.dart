import '../../domain/budget_alert_evaluator.dart';
import '../../domain/entities/progreso_presupuesto.dart';
import '../datasources/budget_alert_state_data_source.dart';
import 'budget_notification_service.dart';

/// Combina el evaluador de alertas (puro) con el estado de
/// deduplicación y el envío real de la notificación local.
class BudgetAlertDispatcher {
  BudgetAlertDispatcher(this._stateDataSource, this._notificationSender);

  final BudgetAlertStateDataSource _stateDataSource;
  final BudgetNotificationSender _notificationSender;

  Future<void> evaluarYNotificar(List<ProgresoPresupuesto> progresos) async {
    final alertas = BudgetAlertEvaluator.evaluar(progresos);
    final ahora = DateTime.now();

    for (final alerta in alertas) {
      final clave = _claveAlerta(alerta, ahora);
      if (_stateDataSource.yaNotificada(clave)) continue;

      final nombre = alerta.progreso.categoria?.nombre ?? 'tu presupuesto total';
      final porcentaje = (alerta.progreso.porcentaje * 100).round();
      final esLimite = alerta.umbral == UmbralPresupuesto.limite100;

      await _notificationSender.mostrarAlerta(
        id: alerta.progreso.presupuesto.id * 10 + (esLimite ? 1 : 0),
        titulo: esLimite ? 'Superaste tu presupuesto' : 'Te acercas a tu límite',
        cuerpo: esLimite
            ? 'Ya usaste el $porcentaje% de $nombre este mes.'
            : 'Vas en el $porcentaje% de $nombre este mes.',
      );
      await _stateDataSource.marcarNotificada(clave);
    }
  }

  String _claveAlerta(AlertaPresupuesto alerta, DateTime ahora) {
    final umbral = alerta.umbral == UmbralPresupuesto.limite100 ? 100 : 80;
    return '${alerta.progreso.presupuesto.id}-$umbral-${ahora.year}-${ahora.month}';
  }
}

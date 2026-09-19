import 'entities/progreso_presupuesto.dart';

enum UmbralPresupuesto { advertencia80, limite100 }

class AlertaPresupuesto {
  const AlertaPresupuesto({required this.progreso, required this.umbral});

  final ProgresoPresupuesto progreso;
  final UmbralPresupuesto umbral;
}

/// Decide qué alertas corresponde disparar (80%/100%, sección 9.5 de
/// CLAUDE.md). Por presupuesto, solo devuelve el umbral más alto
/// alcanzado — si ya pasaste el 100%, no hace falta notificar también
/// el 80%.
abstract final class BudgetAlertEvaluator {
  static List<AlertaPresupuesto> evaluar(
    List<ProgresoPresupuesto> progresos,
  ) {
    final alertas = <AlertaPresupuesto>[];
    for (final progreso in progresos) {
      if (progreso.alcanzoLimite) {
        alertas.add(
          AlertaPresupuesto(
            progreso: progreso,
            umbral: UmbralPresupuesto.limite100,
          ),
        );
      } else if (progreso.alcanzoAdvertencia) {
        alertas.add(
          AlertaPresupuesto(
            progreso: progreso,
            umbral: UmbralPresupuesto.advertencia80,
          ),
        );
      }
    }
    return alertas;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/features/budgets/domain/budget_alert_evaluator.dart';
import 'package:wazuu/features/budgets/domain/entities/presupuesto.dart';
import 'package:wazuu/features/budgets/domain/entities/progreso_presupuesto.dart';

void main() {
  ProgresoPresupuesto progreso({required double gastadoDop, required double limite}) {
    return ProgresoPresupuesto(
      presupuesto: Presupuesto(
        id: 1,
        categoriaId: null,
        montoLimite: limite,
        fechaInicio: DateTime(2026, 9, 1),
      ),
      categoria: null,
      gastadoDop: gastadoDop,
      usdSinConsolidar: false,
    );
  }

  test('sin alcanzar 80%, no hay alerta', () {
    final alertas = BudgetAlertEvaluator.evaluar([
      progreso(gastadoDop: 500, limite: 1000),
    ]);
    expect(alertas, isEmpty);
  });

  test('80%-99% dispara advertencia80', () {
    final alertas = BudgetAlertEvaluator.evaluar([
      progreso(gastadoDop: 850, limite: 1000),
    ]);
    expect(alertas, hasLength(1));
    expect(alertas.single.umbral, UmbralPresupuesto.advertencia80);
  });

  test('100% o más dispara limite100, no ambas', () {
    final alertas = BudgetAlertEvaluator.evaluar([
      progreso(gastadoDop: 1500, limite: 1000),
    ]);
    expect(alertas, hasLength(1));
    expect(alertas.single.umbral, UmbralPresupuesto.limite100);
  });

  test('evalúa varios presupuestos independientemente', () {
    final alertas = BudgetAlertEvaluator.evaluar([
      progreso(gastadoDop: 100, limite: 1000), // sin alerta
      progreso(gastadoDop: 900, limite: 1000), // 80%
      progreso(gastadoDop: 1200, limite: 1000), // 100%
    ]);
    expect(alertas, hasLength(2));
    expect(alertas[0].umbral, UmbralPresupuesto.advertencia80);
    expect(alertas[1].umbral, UmbralPresupuesto.limite100);
  });
}

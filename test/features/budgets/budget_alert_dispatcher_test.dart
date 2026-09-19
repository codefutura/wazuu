import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazuu/features/budgets/data/datasources/budget_alert_state_data_source.dart';
import 'package:wazuu/features/budgets/data/services/budget_alert_dispatcher.dart';
import 'package:wazuu/features/budgets/data/services/budget_notification_service.dart';
import 'package:wazuu/features/budgets/domain/entities/presupuesto.dart';
import 'package:wazuu/features/budgets/domain/entities/progreso_presupuesto.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';

class _RecordingNotificationSender implements BudgetNotificationSender {
  final List<({int id, String titulo, String cuerpo})> enviadas = [];

  @override
  Future<void> mostrarAlerta({
    required int id,
    required String titulo,
    required String cuerpo,
  }) async {
    enviadas.add((id: id, titulo: titulo, cuerpo: cuerpo));
  }
}

void main() {
  const compras = Categoria(
    id: 1,
    nombre: 'Compras',
    tipo: TipoTransaccion.gasto,
    color: '#0F766E',
    icono: 'shopping_bag',
  );

  ProgresoPresupuesto progreso({
    required int id,
    required double gastadoDop,
    required double limite,
  }) {
    return ProgresoPresupuesto(
      presupuesto: Presupuesto(
        id: id,
        categoriaId: compras.id,
        montoLimite: limite,
        fechaInicio: DateTime(2026, 9, 1),
      ),
      categoria: compras,
      gastadoDop: gastadoDop,
      usdSinConsolidar: false,
    );
  }

  late _RecordingNotificationSender sender;
  late BudgetAlertDispatcher dispatcher;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    sender = _RecordingNotificationSender();
    dispatcher = BudgetAlertDispatcher(
      BudgetAlertStateDataSource(prefs),
      sender,
    );
  });

  test('notifica al cruzar el 80%', () async {
    await dispatcher.evaluarYNotificar([
      progreso(id: 1, gastadoDop: 850, limite: 1000),
    ]);

    expect(sender.enviadas, hasLength(1));
    expect(sender.enviadas.single.titulo, 'Te acercas a tu límite');
  });

  test('no repite la misma alerta en una segunda revisión', () async {
    final progresos = [progreso(id: 1, gastadoDop: 850, limite: 1000)];

    await dispatcher.evaluarYNotificar(progresos);
    await dispatcher.evaluarYNotificar(progresos);

    expect(sender.enviadas, hasLength(1));
  });

  test('notifica de nuevo al pasar de 80% a 100% en el mismo mes', () async {
    await dispatcher.evaluarYNotificar([
      progreso(id: 1, gastadoDop: 850, limite: 1000),
    ]);
    await dispatcher.evaluarYNotificar([
      progreso(id: 1, gastadoDop: 1200, limite: 1000),
    ]);

    expect(sender.enviadas, hasLength(2));
    expect(sender.enviadas.last.titulo, 'Superaste tu presupuesto');
  });

  test('presupuestos distintos se notifican de forma independiente', () async {
    await dispatcher.evaluarYNotificar([
      progreso(id: 1, gastadoDop: 850, limite: 1000),
      progreso(id: 2, gastadoDop: 900, limite: 1000),
    ]);

    expect(sender.enviadas, hasLength(2));
  });

  test('sin llegar al 80%, no notifica nada', () async {
    await dispatcher.evaluarYNotificar([
      progreso(id: 1, gastadoDop: 100, limite: 1000),
    ]);

    expect(sender.enviadas, isEmpty);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/core/theme/app_theme.dart';
import 'package:wazuu/features/budgets/data/datasources/budget_alert_state_data_source.dart';
import 'package:wazuu/features/budgets/data/providers/budget_alert_dispatcher_provider.dart';
import 'package:wazuu/features/budgets/data/providers/presupuestos_repository_provider.dart';
import 'package:wazuu/features/budgets/data/services/budget_alert_dispatcher.dart';
import 'package:wazuu/features/budgets/data/services/budget_notification_service.dart';
import 'package:wazuu/features/budgets/domain/entities/presupuesto.dart';
import 'package:wazuu/features/budgets/domain/repositories/presupuestos_repository.dart';
import 'package:wazuu/features/budgets/presentation/screens/budgets_screen.dart';
import 'package:wazuu/features/categorization/data/providers/categorization_providers.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/features/categorization/domain/repositories/categorias_repository.dart';
import 'package:wazuu/features/settings/data/providers/usuario_settings_repository_provider.dart';
import 'package:wazuu/features/settings/domain/repositories/usuario_settings_repository.dart';
import 'package:wazuu/features/transactions/data/providers/transacciones_repository_provider.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_huerfana.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_registro.dart';
import 'package:wazuu/features/transactions/domain/repositories/transacciones_repository.dart';

class _InMemoryPresupuestosRepository implements PresupuestosRepository {
  final List<Presupuesto> _items = [];
  int _nextId = 1;

  @override
  Future<List<Presupuesto>> obtenerTodos() async => List.unmodifiable(_items);

  @override
  Future<void> crear({
    required int? categoriaId,
    required double montoLimite,
    required DateTime fechaInicio,
  }) async {
    _items.add(
      Presupuesto(
        id: _nextId++,
        categoriaId: categoriaId,
        montoLimite: montoLimite,
        fechaInicio: fechaInicio,
      ),
    );
  }

  @override
  Future<void> actualizarMonto({required int id, required double montoLimite}) async {}

  @override
  Future<void> eliminar(int id) async {}
}

class _EmptyTransaccionesRepository implements TransaccionesRepository {
  @override
  Future<List<TransaccionRegistro>> obtener({
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    int? tarjetaId,
  }) async => [];

  @override
  Future<void> actualizarCategoria({
    required int transaccionId,
    required int categoriaId,
  }) async {}

  @override
  Future<bool> insertar({
    required double monto,
    required Moneda moneda,
    required DateTime fecha,
    required String comercio,
    required EstadoTransaccion estado,
    required TipoTransaccion tipoTransaccion,
    required int categoriaId,
    int? tarjetaId,
    required int bancoId,
    required String emailIdOrigen,
    required String hashDedupe,
    String? tarjetaUltimos4Digitos,
  }) async => true;

  @override
  Future<int> reasignarTarjetaHuerfanas({
    required int bancoId,
    required String ultimos4Digitos,
    required int tarjetaId,
  }) async => 0;

  @override
  Future<List<TransaccionHuerfana>> obtenerHuerfanasPorBanco(
    int bancoId,
  ) async => [];

  @override
  Future<void> vincularTarjeta({
    required int transaccionId,
    required int tarjetaId,
    required String tarjetaUltimos4Digitos,
  }) async {}
}

const _compras = Categoria(
  id: 1,
  nombre: 'Compras',
  tipo: TipoTransaccion.gasto,
  color: '#0F766E',
  icono: 'shopping_bag',
);

class _ConCategoriasRepository implements CategoriasRepository {
  @override
  Future<List<Categoria>> obtenerTodas() async => const [_compras];

  @override
  Future<Categoria> obtenerCategoriaOtro(TipoTransaccion tipo) async => _compras;
}

class _NullTasaSettingsRepository implements UsuarioSettingsRepository {
  @override
  Future<double?> obtenerTasaCambioReferencia() async => null;

  @override
  Future<void> establecerTasaCambioReferencia(double tasa) async {}
}

void main() {
  testWidgets('Estado vacío y creación de un presupuesto nuevo', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          presupuestosRepositoryProvider.overrideWith(
            (ref) async => _InMemoryPresupuestosRepository(),
          ),
          transaccionesRepositoryProvider.overrideWith(
            (ref) async => _EmptyTransaccionesRepository(),
          ),
          categoriasRepositoryProvider.overrideWith(
            (ref) async => _ConCategoriasRepository(),
          ),
          usuarioSettingsRepositoryProvider.overrideWith(
            (ref) async => _NullTasaSettingsRepository(),
          ),
          budgetAlertDispatcherProvider.overrideWith(
            (ref) async => BudgetAlertDispatcher(
              BudgetAlertStateDataSource(prefs),
              _NoopNotificationSender(),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const BudgetsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aún no tienes presupuestos'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo presupuesto'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '5000');
    await tester.tap(find.text('Crear presupuesto'));
    await tester.pumpAndSettle();

    expect(find.text('Presupuesto total'), findsOneWidget);
    expect(find.textContaining('RD\$5,000.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _NoopNotificationSender implements BudgetNotificationSender {
  @override
  Future<void> mostrarAlerta({
    required int id,
    required String titulo,
    required String cuerpo,
  }) async {}
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/budgets/domain/entities/presupuesto.dart';
import 'package:wazuu/features/budgets/domain/progreso_presupuestos_calculator.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_registro.dart';

void main() {
  const compras = Categoria(
    id: 1,
    nombre: 'Compras',
    tipo: TipoTransaccion.gasto,
    color: '#0F766E',
    icono: 'shopping_bag',
  );
  const alimentos = Categoria(
    id: 2,
    nombre: 'Alimentos',
    tipo: TipoTransaccion.gasto,
    color: '#F59E0B',
    icono: 'restaurant',
  );

  var nextId = 1;
  TransaccionRegistro gasto({
    required double monto,
    required Moneda moneda,
    required Categoria categoria,
    EstadoTransaccion estado = EstadoTransaccion.aprobada,
    TipoTransaccion tipo = TipoTransaccion.gasto,
  }) {
    return TransaccionRegistro(
      id: nextId++,
      monto: monto,
      moneda: moneda,
      fecha: DateTime(2026, 9, 10),
      comercio: 'Comercio',
      estado: estado,
      tipoTransaccion: tipo,
      categoria: categoria,
      bancoId: 1,
      nombreBanco: 'Banco',
    );
  }

  const calculator = ProgresoPresupuestosCalculator();

  test('presupuesto por categoría solo cuenta gastos de esa categoría', () {
    final presupuesto = Presupuesto(
      id: 1,
      categoriaId: compras.id,
      montoLimite: 1000,
      fechaInicio: DateTime(2026, 9, 1),
    );

    final progresos = calculator.calcular(
      presupuestos: [presupuesto],
      transaccionesDelPeriodo: [
        gasto(monto: 300, moneda: Moneda.dop, categoria: compras),
        gasto(monto: 500, moneda: Moneda.dop, categoria: alimentos),
      ],
      categorias: const [compras, alimentos],
    );

    expect(progresos.single.gastadoDop, 300);
    expect(progresos.single.porcentaje, 0.3);
  });

  test('presupuesto total (categoriaId null) suma todos los gastos', () {
    final presupuesto = Presupuesto(
      id: 1,
      categoriaId: null,
      montoLimite: 1000,
      fechaInicio: DateTime(2026, 9, 1),
    );

    final progresos = calculator.calcular(
      presupuestos: [presupuesto],
      transaccionesDelPeriodo: [
        gasto(monto: 300, moneda: Moneda.dop, categoria: compras),
        gasto(monto: 500, moneda: Moneda.dop, categoria: alimentos),
      ],
      categorias: const [compras, alimentos],
    );

    expect(progresos.single.gastadoDop, 800);
    expect(progresos.single.categoria, isNull);
  });

  test('ignora ingresos y transacciones declinadas', () {
    final presupuesto = Presupuesto(
      id: 1,
      categoriaId: null,
      montoLimite: 1000,
      fechaInicio: DateTime(2026, 9, 1),
    );

    final progresos = calculator.calcular(
      presupuestos: [presupuesto],
      transaccionesDelPeriodo: [
        gasto(monto: 300, moneda: Moneda.dop, categoria: compras, tipo: TipoTransaccion.ingreso),
        gasto(monto: 500, moneda: Moneda.dop, categoria: compras, estado: EstadoTransaccion.declinada),
      ],
      categorias: const [compras],
    );

    expect(progresos.single.gastadoDop, 0);
  });

  test('consolida USD si hay tasa, y avisa si no la hay', () {
    final presupuesto = Presupuesto(
      id: 1,
      categoriaId: null,
      montoLimite: 1000,
      fechaInicio: DateTime(2026, 9, 1),
    );
    final transacciones = [
      gasto(monto: 100, moneda: Moneda.dop, categoria: compras),
      gasto(monto: 10, moneda: Moneda.usd, categoria: compras),
    ];

    final conTasa = calculator.calcular(
      presupuestos: [presupuesto],
      transaccionesDelPeriodo: transacciones,
      categorias: const [compras],
      tasaCambioReferencia: 60,
    );
    expect(conTasa.single.gastadoDop, 700);
    expect(conTasa.single.usdSinConsolidar, isFalse);

    final sinTasa = calculator.calcular(
      presupuestos: [presupuesto],
      transaccionesDelPeriodo: transacciones,
      categorias: const [compras],
    );
    expect(sinTasa.single.gastadoDop, 100);
    expect(sinTasa.single.usdSinConsolidar, isTrue);
  });

  test('alcanzoAdvertencia y alcanzoLimite en los umbrales correctos', () {
    final presupuesto = Presupuesto(
      id: 1,
      categoriaId: null,
      montoLimite: 1000,
      fechaInicio: DateTime(2026, 9, 1),
    );

    final al80 = calculator.calcular(
      presupuestos: [presupuesto],
      transaccionesDelPeriodo: [
        gasto(monto: 800, moneda: Moneda.dop, categoria: compras),
      ],
      categorias: const [compras],
    ).single;
    expect(al80.alcanzoAdvertencia, isTrue);
    expect(al80.alcanzoLimite, isFalse);

    final al100 = calculator.calcular(
      presupuestos: [presupuesto],
      transaccionesDelPeriodo: [
        gasto(monto: 1200, moneda: Moneda.dop, categoria: compras),
      ],
      categorias: const [compras],
    ).single;
    expect(al100.alcanzoAdvertencia, isTrue);
    expect(al100.alcanzoLimite, isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/features/home/domain/resumen_mensual_calculator.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_registro.dart';

void main() {
  const categoria = Categoria(
    id: 1,
    nombre: 'Compras',
    tipo: TipoTransaccion.gasto,
    color: '#0F766E',
    icono: 'shopping_bag',
  );
  const categoriaIngreso = Categoria(
    id: 8,
    nombre: 'Nómina',
    tipo: TipoTransaccion.ingreso,
    color: '#22C55E',
    icono: 'payments',
  );

  var nextId = 1;
  TransaccionRegistro transaccion({
    required double monto,
    required Moneda moneda,
    required DateTime fecha,
    required TipoTransaccion tipo,
    EstadoTransaccion estado = EstadoTransaccion.aprobada,
    Categoria? categoriaOverride,
  }) {
    return TransaccionRegistro(
      id: nextId++,
      monto: monto,
      moneda: moneda,
      fecha: fecha,
      comercio: 'Comercio',
      estado: estado,
      tipoTransaccion: tipo,
      categoria:
          categoriaOverride ??
          (tipo == TipoTransaccion.gasto ? categoria : categoriaIngreso),
      bancoId: 1,
      nombreBanco: 'Banco',
    );
  }

  const calculator = ResumenMensualCalculator();
  final mesObjetivo = DateTime(2026, 9, 1);

  test('sin transacciones, todo en cero y sin tendencia si no hay tasa', () {
    final resumen = calculator.calcular(
      transacciones: const [],
      mesObjetivo: mesObjetivo,
    );

    expect(resumen.ingresosDop, 0);
    expect(resumen.gastosDop, 0);
    expect(resumen.totalTransacciones, 0);
    expect(resumen.variacionVsMesAnteriorPorcentaje, isNull);
    expect(resumen.tendenciaMensual, isEmpty);
    expect(resumen.balanceNetoConsolidadoDop, isNull);
  });

  test('suma ingresos y gastos del mes por moneda, ignora otros meses', () {
    final transacciones = [
      transaccion(
        monto: 1000,
        moneda: Moneda.dop,
        fecha: DateTime(2026, 9, 5),
        tipo: TipoTransaccion.ingreso,
      ),
      transaccion(
        monto: 200,
        moneda: Moneda.dop,
        fecha: DateTime(2026, 9, 10),
        tipo: TipoTransaccion.gasto,
      ),
      transaccion(
        monto: 50,
        moneda: Moneda.usd,
        fecha: DateTime(2026, 9, 12),
        tipo: TipoTransaccion.gasto,
      ),
      // Mes distinto — no debe contar.
      transaccion(
        monto: 999,
        moneda: Moneda.dop,
        fecha: DateTime(2026, 8, 1),
        tipo: TipoTransaccion.gasto,
      ),
    ];

    final resumen = calculator.calcular(
      transacciones: transacciones,
      mesObjetivo: mesObjetivo,
      tasaCambioReferencia: 60,
    );

    expect(resumen.ingresosDop, 1000);
    expect(resumen.gastosDop, 200);
    expect(resumen.gastosUsd, 50);
    expect(resumen.totalTransacciones, 3);
    // Consolidado: (1000) - (200 + 50*60) = 1000 - 3200 = -2200.
    expect(resumen.balanceNetoConsolidadoDop, -2200);
  });

  test('ignora transacciones declinadas', () {
    final transacciones = [
      transaccion(
        monto: 500,
        moneda: Moneda.dop,
        fecha: DateTime(2026, 9, 5),
        tipo: TipoTransaccion.gasto,
        estado: EstadoTransaccion.declinada,
      ),
    ];

    final resumen = calculator.calcular(
      transacciones: transacciones,
      mesObjetivo: mesObjetivo,
      tasaCambioReferencia: 60,
    );

    expect(resumen.gastosDop, 0);
  });

  test('calcula variación vs. el mes anterior', () {
    final transacciones = [
      // Mes anterior: balance neto 500 DOP.
      transaccion(
        monto: 500,
        moneda: Moneda.dop,
        fecha: DateTime(2026, 8, 5),
        tipo: TipoTransaccion.ingreso,
      ),
      // Mes actual: balance neto 1000 DOP (+100%).
      transaccion(
        monto: 1000,
        moneda: Moneda.dop,
        fecha: DateTime(2026, 9, 5),
        tipo: TipoTransaccion.ingreso,
      ),
    ];

    final resumen = calculator.calcular(
      transacciones: transacciones,
      mesObjetivo: mesObjetivo,
      tasaCambioReferencia: 60,
    );

    expect(resumen.variacionVsMesAnteriorPorcentaje, 100);
  });

  test('sin tasa de cambio configurada, no consolida ni arma tendencia', () {
    final transacciones = [
      transaccion(
        monto: 1000,
        moneda: Moneda.dop,
        fecha: DateTime(2026, 9, 5),
        tipo: TipoTransaccion.ingreso,
      ),
    ];

    final resumen = calculator.calcular(
      transacciones: transacciones,
      mesObjetivo: mesObjetivo,
    );

    expect(resumen.balanceNetoConsolidadoDop, isNull);
    expect(resumen.tendenciaMensual, isEmpty);
    expect(resumen.ingresosDop, 1000);
  });

  test('la tendencia de 6 meses cubre de mesObjetivo-5 a mesObjetivo', () {
    final resumen = calculator.calcular(
      transacciones: const [],
      mesObjetivo: mesObjetivo,
      tasaCambioReferencia: 60,
    );

    expect(resumen.tendenciaMensual, hasLength(6));
    expect(resumen.tendenciaMensual.first.mes, DateTime(2026, 4));
    expect(resumen.tendenciaMensual.last.mes, DateTime(2026, 9));
  });

  test('mesesTendencia controla cuántos meses cubre la tendencia', () {
    final resumenTresMeses = calculator.calcular(
      transacciones: const [],
      mesObjetivo: mesObjetivo,
      tasaCambioReferencia: 60,
      mesesTendencia: 3,
    );

    expect(resumenTresMeses.tendenciaMensual, hasLength(3));
    expect(resumenTresMeses.tendenciaMensual.first.mes, DateTime(2026, 7));
    expect(resumenTresMeses.tendenciaMensual.last.mes, DateTime(2026, 9));

    final resumenDoceMeses = calculator.calcular(
      transacciones: const [],
      mesObjetivo: mesObjetivo,
      tasaCambioReferencia: 60,
      mesesTendencia: 12,
    );

    expect(resumenDoceMeses.tendenciaMensual, hasLength(12));
    expect(resumenDoceMeses.tendenciaMensual.first.mes, DateTime(2025, 10));
  });

  group('gastoPorCategoria', () {
    const alimentos = Categoria(
      id: 2,
      nombre: 'Alimentos',
      tipo: TipoTransaccion.gasto,
      color: '#F59E0B',
      icono: 'restaurant',
    );

    test('agrupa el gasto del mes actual por categoría, de mayor a menor', () {
      final resumen = calculator.calcular(
        transacciones: [
          transaccion(
            monto: 100,
            moneda: Moneda.dop,
            fecha: DateTime(2026, 9, 5),
            tipo: TipoTransaccion.gasto,
            categoriaOverride: categoria,
          ),
          transaccion(
            monto: 50,
            moneda: Moneda.dop,
            fecha: DateTime(2026, 9, 6),
            tipo: TipoTransaccion.gasto,
            categoriaOverride: categoria,
          ),
          transaccion(
            monto: 300,
            moneda: Moneda.dop,
            fecha: DateTime(2026, 9, 7),
            tipo: TipoTransaccion.gasto,
            categoriaOverride: alimentos,
          ),
        ],
        mesObjetivo: mesObjetivo,
      );

      expect(resumen.gastoPorCategoria, hasLength(2));
      expect(resumen.gastoPorCategoria.first.categoria.nombre, 'Alimentos');
      expect(resumen.gastoPorCategoria.first.montoDop, 300);
      expect(resumen.gastoPorCategoria.last.categoria.nombre, 'Compras');
      expect(resumen.gastoPorCategoria.last.montoDop, 150);
    });

    test('ignora ingresos y transacciones declinadas', () {
      final resumen = calculator.calcular(
        transacciones: [
          transaccion(
            monto: 1000,
            moneda: Moneda.dop,
            fecha: DateTime(2026, 9, 1),
            tipo: TipoTransaccion.ingreso,
          ),
          transaccion(
            monto: 500,
            moneda: Moneda.dop,
            fecha: DateTime(2026, 9, 2),
            tipo: TipoTransaccion.gasto,
            estado: EstadoTransaccion.declinada,
          ),
        ],
        mesObjetivo: mesObjetivo,
      );

      expect(resumen.gastoPorCategoria, isEmpty);
    });

    test('separa DOP y USD dentro de la misma categoría', () {
      final resumen = calculator.calcular(
        transacciones: [
          transaccion(
            monto: 100,
            moneda: Moneda.dop,
            fecha: DateTime(2026, 9, 5),
            tipo: TipoTransaccion.gasto,
            categoriaOverride: categoria,
          ),
          transaccion(
            monto: 20,
            moneda: Moneda.usd,
            fecha: DateTime(2026, 9, 6),
            tipo: TipoTransaccion.gasto,
            categoriaOverride: categoria,
          ),
        ],
        mesObjetivo: mesObjetivo,
      );

      expect(resumen.gastoPorCategoria, hasLength(1));
      expect(resumen.gastoPorCategoria.single.montoDop, 100);
      expect(resumen.gastoPorCategoria.single.montoUsd, 20);
    });

    test('sin transacciones del mes, lista vacía', () {
      final resumen = calculator.calcular(
        transacciones: const [],
        mesObjetivo: mesObjetivo,
      );

      expect(resumen.gastoPorCategoria, isEmpty);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_registro.dart';
import 'package:wazuu/features/transactions/domain/totales_transacciones_calculator.dart';

void main() {
  const compras = Categoria(
    id: 1,
    nombre: 'Compras',
    tipo: TipoTransaccion.gasto,
    color: '#0F766E',
    icono: 'shopping_bag',
  );
  const nomina = Categoria(
    id: 2,
    nombre: 'Nómina',
    tipo: TipoTransaccion.ingreso,
    color: '#22C55E',
    icono: 'payments',
  );

  TransaccionRegistro t({
    required double monto,
    required Moneda moneda,
    required TipoTransaccion tipo,
    EstadoTransaccion estado = EstadoTransaccion.aprobada,
  }) {
    return TransaccionRegistro(
      id: 1,
      monto: monto,
      moneda: moneda,
      fecha: DateTime(2026, 9, 1),
      comercio: 'Comercio',
      estado: estado,
      tipoTransaccion: tipo,
      categoria: tipo == TipoTransaccion.gasto ? compras : nomina,
      bancoId: 1,
      nombreBanco: 'Banco',
    );
  }

  const calculator = TotalesTransaccionesCalculator();

  test('suma ingresos y gastos por separado, por moneda', () {
    final resultado = calculator.calcular([
      t(monto: 100, moneda: Moneda.dop, tipo: TipoTransaccion.gasto),
      t(monto: 50, moneda: Moneda.dop, tipo: TipoTransaccion.gasto),
      t(monto: 1000, moneda: Moneda.dop, tipo: TipoTransaccion.ingreso),
      t(monto: 20, moneda: Moneda.usd, tipo: TipoTransaccion.gasto),
    ]);

    expect(resultado.gastosDop, 150);
    expect(resultado.ingresosDop, 1000);
    expect(resultado.gastosUsd, 20);
    expect(resultado.ingresosUsd, 0);
    expect(resultado.balanceDop, 850);
    expect(resultado.hayMovimientoUsd, isTrue);
  });

  test('ignora transacciones declinadas', () {
    final resultado = calculator.calcular([
      t(
        monto: 500,
        moneda: Moneda.dop,
        tipo: TipoTransaccion.gasto,
        estado: EstadoTransaccion.declinada,
      ),
      t(monto: 100, moneda: Moneda.dop, tipo: TipoTransaccion.gasto),
    ]);

    expect(resultado.gastosDop, 100);
  });

  test('lista vacía da totales en cero, sin movimiento USD', () {
    final resultado = calculator.calcular([]);

    expect(resultado.balanceDop, 0);
    expect(resultado.hayMovimientoUsd, isFalse);
  });
}

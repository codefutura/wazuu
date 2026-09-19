import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_registro.dart';
import 'package:wazuu/features/transactions/domain/totales_por_banco_calculator.dart';

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
    required TipoTransaccion tipo,
    required String banco,
    EstadoTransaccion estado = EstadoTransaccion.aprobada,
  }) {
    return TransaccionRegistro(
      id: 1,
      monto: monto,
      moneda: Moneda.dop,
      fecha: DateTime(2026, 9, 1),
      comercio: 'Comercio',
      estado: estado,
      tipoTransaccion: tipo,
      categoria: tipo == TipoTransaccion.gasto ? compras : nomina,
      bancoId: banco == 'BHD' ? 1 : 2,
      nombreBanco: banco,
    );
  }

  const calculator = TotalesPorBancoCalculator();

  test('agrupa por banco, ordenado alfabéticamente', () {
    final resultado = calculator.calcular([
      t(monto: 100, tipo: TipoTransaccion.gasto, banco: 'Banco Popular'),
      t(monto: 50, tipo: TipoTransaccion.gasto, banco: 'BHD'),
      t(monto: 1000, tipo: TipoTransaccion.ingreso, banco: 'BHD'),
    ]);

    expect(resultado, hasLength(2));
    expect(resultado[0].nombreBanco, 'BHD');
    expect(resultado[0].totales.gastosDop, 50);
    expect(resultado[0].totales.ingresosDop, 1000);
    expect(resultado[1].nombreBanco, 'Banco Popular');
    expect(resultado[1].totales.gastosDop, 100);
  });

  test('ignora transacciones declinadas dentro de cada banco', () {
    final resultado = calculator.calcular([
      t(
        monto: 500,
        tipo: TipoTransaccion.gasto,
        banco: 'BHD',
        estado: EstadoTransaccion.declinada,
      ),
      t(monto: 30, tipo: TipoTransaccion.gasto, banco: 'BHD'),
    ]);

    expect(resultado.single.totales.gastosDop, 30);
  });

  test('lista vacía da lista vacía', () {
    expect(calculator.calcular([]), isEmpty);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/cards/domain/consumo_tarjetas_calculator.dart';
import 'package:wazuu/features/cards/domain/entities/tarjeta.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_registro.dart';

void main() {
  const categoria = Categoria(
    id: 1,
    nombre: 'Compras',
    tipo: TipoTransaccion.gasto,
    color: '#0F766E',
    icono: 'shopping_bag',
  );

  const debito = Tarjeta(
    id: 1,
    apodo: 'Débito BHD',
    ultimos4Digitos: '5472',
    tipo: TipoTarjeta.debito,
    bancoId: 1,
    nombreBanco: 'BHD',
  );
  const credito = Tarjeta(
    id: 2,
    apodo: 'Visa Gold',
    ultimos4Digitos: '2319',
    tipo: TipoTarjeta.credito,
    bancoId: 2,
    nombreBanco: 'Banco Popular Dominicano',
    limiteCredito: 1000,
  );

  var nextId = 1;
  TransaccionRegistro transaccion({
    required double monto,
    required Moneda moneda,
    required int tarjetaId,
    TipoTransaccion tipo = TipoTransaccion.gasto,
    EstadoTransaccion estado = EstadoTransaccion.aprobada,
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
      tarjetaId: tarjetaId,
      bancoId: 1,
      nombreBanco: 'Banco',
    );
  }

  const calculator = ConsumoTarjetasCalculator();

  test('suma el consumo por tarjeta y por moneda', () {
    final consumos = calculator.calcular(
      tarjetas: const [debito, credito],
      transaccionesDelPeriodo: [
        transaccion(monto: 100, moneda: Moneda.dop, tarjetaId: debito.id),
        transaccion(monto: 200, moneda: Moneda.dop, tarjetaId: credito.id),
        transaccion(monto: 50, moneda: Moneda.usd, tarjetaId: credito.id),
      ],
    );

    final consumoDebito = consumos.firstWhere((c) => c.tarjeta.id == debito.id);
    final consumoCredito = consumos.firstWhere((c) => c.tarjeta.id == credito.id);

    expect(consumoDebito.consumoDop, 100);
    expect(consumoCredito.consumoDop, 200);
    expect(consumoCredito.consumoUsd, 50);
  });

  test('ignora ingresos y transacciones declinadas', () {
    final consumos = calculator.calcular(
      tarjetas: const [debito],
      transaccionesDelPeriodo: [
        transaccion(
          monto: 100,
          moneda: Moneda.dop,
          tarjetaId: debito.id,
          tipo: TipoTransaccion.ingreso,
        ),
        transaccion(
          monto: 200,
          moneda: Moneda.dop,
          tarjetaId: debito.id,
          estado: EstadoTransaccion.declinada,
        ),
      ],
    );

    expect(consumos.single.consumoDop, 0);
  });

  test('progresoLimite es null para débito y calcula % para crédito', () {
    final consumos = calculator.calcular(
      tarjetas: const [debito, credito],
      transaccionesDelPeriodo: [
        transaccion(monto: 100, moneda: Moneda.dop, tarjetaId: debito.id),
        transaccion(monto: 250, moneda: Moneda.dop, tarjetaId: credito.id),
      ],
    );

    final consumoDebito = consumos.firstWhere((c) => c.tarjeta.id == debito.id);
    final consumoCredito = consumos.firstWhere((c) => c.tarjeta.id == credito.id);

    expect(consumoDebito.progresoLimite, isNull);
    expect(consumoCredito.progresoLimite, 0.25);
  });

  test('consolidadoDop sin consumo en USD no depende de la tasa', () {
    final consumos = calculator.calcular(
      tarjetas: const [debito],
      transaccionesDelPeriodo: [
        transaccion(monto: 100, moneda: Moneda.dop, tarjetaId: debito.id),
      ],
    );

    expect(calculator.consolidadoDop(consumos, null), 100);
  });

  test('consolidadoDop es null si hay USD y no hay tasa configurada', () {
    final consumos = calculator.calcular(
      tarjetas: const [credito],
      transaccionesDelPeriodo: [
        transaccion(monto: 50, moneda: Moneda.usd, tarjetaId: credito.id),
      ],
    );

    expect(calculator.consolidadoDop(consumos, null), isNull);
    expect(calculator.consolidadoDop(consumos, 60), 3000);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_registro.dart';
import 'package:wazuu/features/transactions/presentation/widgets/transaccion_detalle_dialog.dart';

void main() {
  const categoria = Categoria(
    id: 1,
    nombre: 'Compras',
    tipo: TipoTransaccion.gasto,
    color: '#0F766E',
    icono: 'shopping_bag',
  );

  Widget envolver(TransaccionRegistro transaccion) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () =>
                TransaccionDetalleDialog.mostrar(context, transaccion),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );
  }

  testWidgets('muestra los datos completos de una transacción con tarjeta', (
    tester,
  ) async {
    final transaccion = TransaccionRegistro(
      id: 1,
      monto: 185.14,
      moneda: Moneda.dop,
      fecha: DateTime(2026, 9, 15),
      comercio: 'CFN FERRECENTRO',
      estado: EstadoTransaccion.aprobada,
      tipoTransaccion: TipoTransaccion.gasto,
      categoria: categoria,
      bancoId: 1,
      nombreBanco: 'Banco Popular Dominicano',
      tarjetaId: 5,
      tarjetaApodo: 'Visa Gold',
      tarjetaUltimos4Digitos: '2319',
    );

    await tester.pumpWidget(envolver(transaccion));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('CFN FERRECENTRO'), findsOneWidget);
    expect(find.text('-RD\$185.14'), findsOneWidget);
    expect(find.text('15 de septiembre de 2026'), findsOneWidget);
    expect(find.text('Compras'), findsOneWidget);
    expect(find.text('Gasto'), findsOneWidget);
    expect(find.text('Aprobada'), findsOneWidget);
    expect(find.text('Banco Popular Dominicano'), findsOneWidget);
    expect(find.text('Visa Gold (•••• 2319)'), findsOneWidget);
  });

  testWidgets('sin tarjeta vinculada, lo dice explícitamente', (
    tester,
  ) async {
    final transaccion = TransaccionRegistro(
      id: 2,
      monto: 50,
      moneda: Moneda.usd,
      fecha: DateTime(2026, 9, 10),
      comercio: 'Comercio sin tarjeta',
      estado: EstadoTransaccion.declinada,
      tipoTransaccion: TipoTransaccion.gasto,
      categoria: categoria,
      bancoId: 1,
      nombreBanco: 'BHD',
    );

    await tester.pumpWidget(envolver(transaccion));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Sin vincular todavía'), findsOneWidget);
    expect(find.text('Declinada'), findsOneWidget);
  });
}

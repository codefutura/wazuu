import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wazuu/core/database/db_schema.dart';
import 'package:wazuu/features/banks/data/datasources/banks_sql_data_source.dart';
import 'package:wazuu/features/banks/domain/entities/bank_option.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late Database db;
  late BanksSqlDataSource dataSource;

  setUp(() async {
    db = await createInMemoryTestDatabase();
    dataSource = BanksSqlDataSource(db);
  });

  tearDown(() => db.close());

  const banreservas = BankOption(
    id: 'banreservas',
    name: 'Banreservas',
    senderEmail: 'alertas@banreservas.com',
  );
  const bhd = BankOption(
    id: 'bhd',
    name: 'BHD',
    senderEmail: 'alertas@bhd.com.do',
  );

  test('conecta bancos nuevos', () async {
    await dataSource.replaceConnected([banreservas, bhd]);

    final nombres = await dataSource.readConnectedNames();
    expect(nombres, {'Banreservas', 'BHD'});
  });

  test(
    'editar la selección conserva el id de bancos que ya existían — no rompe FKs',
    () async {
      await dataSource.replaceConnected([banreservas, bhd]);
      final idsOriginales = {
        for (final row in await dataSource.readConnectedRows())
          row.nombreBanco: row.id,
      };

      // El usuario quita BHD y deja solo Banreservas.
      await dataSource.replaceConnected([banreservas]);

      final rows = await dataSource.readConnectedRows();
      expect(rows, hasLength(1));
      expect(rows.single.nombreBanco, 'Banreservas');
      // El id de Banreservas debe ser el mismo que antes.
      expect(rows.single.id, idsOriginales['Banreservas']);
    },
  );

  test('un banco desmarcado queda con activo = 0, no se borra', () async {
    await dataSource.replaceConnected([banreservas, bhd]);
    await dataSource.replaceConnected([banreservas]);

    final todasLasFilas = await db.query(BancosConectadosTable.table);
    expect(todasLasFilas, hasLength(2)); // BHD sigue existiendo en la tabla.
    final bhdRow = todasLasFilas.firstWhere(
      (row) => row[BancosConectadosTable.nombreBanco] == 'BHD',
    );
    expect(bhdRow[BancosConectadosTable.activo], 0);
  });

  test('reconectar un banco previamente desmarcado lo reactiva', () async {
    await dataSource.replaceConnected([banreservas, bhd]);
    await dataSource.replaceConnected([banreservas]);
    await dataSource.replaceConnected([banreservas, bhd]);

    final nombres = await dataSource.readConnectedNames();
    expect(nombres, {'Banreservas', 'BHD'});
  });

  test(
    'guardar de nuevo un banco ya conectado refresca su remitente_email',
    () async {
      const bhdConRemitenteViejo = BankOption(
        id: 'bhd',
        name: 'BHD',
        senderEmail: 'notificaciones@bhd.com.do',
      );
      await dataSource.replaceConnected([bhdConRemitenteViejo]);

      const bhdConRemitenteCorregido = BankOption(
        id: 'bhd',
        name: 'BHD',
        senderEmail: 'alertas@bhd.com.do',
      );
      await dataSource.replaceConnected([bhdConRemitenteCorregido]);

      final rows = await dataSource.readConnectedRows();
      expect(rows.single.remitenteEmail, 'alertas@bhd.com.do');
    },
  );
}

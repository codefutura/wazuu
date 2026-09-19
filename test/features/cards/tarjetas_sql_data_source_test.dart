import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wazuu/core/database/db_schema.dart';
import 'package:wazuu/features/cards/data/datasources/tarjetas_sql_data_source.dart';
import 'package:wazuu/features/cards/domain/entities/tarjeta.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late Database db;
  late TarjetasSqlDataSource dataSource;
  late int bancoId;

  setUp(() async {
    db = await createInMemoryTestDatabase();
    dataSource = TarjetasSqlDataSource(db);
    bancoId = await db.insert(BancosConectadosTable.table, {
      BancosConectadosTable.nombreBanco: 'BHD',
      BancosConectadosTable.remitenteEmail: 'alertas@bhd.com.do',
      BancosConectadosTable.activo: 1,
    });
  });

  tearDown(() => db.close());

  test('crea y lee una tarjeta de crédito con límite', () async {
    await dataSource.crear(
      apodo: 'Visa Gold',
      ultimos4Digitos: '2319',
      tipo: TipoTarjeta.credito,
      bancoId: bancoId,
      limiteCredito: 50000,
    );

    final tarjetas = await dataSource.obtenerTodas();
    expect(tarjetas, hasLength(1));
    expect(tarjetas.single.apodo, 'Visa Gold');
    expect(tarjetas.single.tipo, TipoTarjeta.credito);
    expect(tarjetas.single.limiteCredito, 50000);
    expect(tarjetas.single.nombreBanco, 'BHD');
  });

  test('crea una tarjeta de débito sin límite', () async {
    await dataSource.crear(
      apodo: 'Débito BHD',
      ultimos4Digitos: '5472',
      tipo: TipoTarjeta.debito,
      bancoId: bancoId,
    );

    final tarjeta = (await dataSource.obtenerTodas()).single;
    expect(tarjeta.tipo, TipoTarjeta.debito);
    expect(tarjeta.limiteCredito, isNull);
  });

  test('actualizar cambia el apodo y el límite', () async {
    await dataSource.crear(
      apodo: 'Visa Gold',
      ultimos4Digitos: '2319',
      tipo: TipoTarjeta.credito,
      bancoId: bancoId,
      limiteCredito: 50000,
    );
    final id = (await dataSource.obtenerTodas()).single.id;

    await dataSource.actualizar(
      id: id,
      apodo: 'Visa Gold (renombrada)',
      limiteCredito: 75000,
    );

    final tarjeta = (await dataSource.obtenerTodas()).single;
    expect(tarjeta.apodo, 'Visa Gold (renombrada)');
    expect(tarjeta.limiteCredito, 75000);
  });

  test('eliminar quita la tarjeta', () async {
    await dataSource.crear(
      apodo: 'Visa Gold',
      ultimos4Digitos: '2319',
      tipo: TipoTarjeta.credito,
      bancoId: bancoId,
    );
    final id = (await dataSource.obtenerTodas()).single.id;

    await dataSource.eliminar(id);

    expect(await dataSource.obtenerTodas(), isEmpty);
  });

  test('obtenerPorUltimos4Digitos encuentra la tarjeta correcta', () async {
    await dataSource.crear(
      apodo: 'Visa Gold',
      ultimos4Digitos: '2319',
      tipo: TipoTarjeta.credito,
      bancoId: bancoId,
    );

    final encontrada = await dataSource.obtenerPorUltimos4Digitos(
      bancoId: bancoId,
      ultimos4Digitos: '2319',
    );
    expect(encontrada?.apodo, 'Visa Gold');
    expect(encontrada?.nombreBanco, 'BHD');

    final noEncontrada = await dataSource.obtenerPorUltimos4Digitos(
      bancoId: bancoId,
      ultimos4Digitos: '9999',
    );
    expect(noEncontrada, isNull);
  });
}

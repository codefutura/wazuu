import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wazuu/core/database/db_schema.dart';
import 'package:wazuu/features/settings/data/datasources/usuario_settings_sql_data_source.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late Database db;
  late UsuarioSettingsSqlDataSource dataSource;

  setUp(() async {
    db = await createInMemoryTestDatabase();
    dataSource = UsuarioSettingsSqlDataSource(db);
    await db.insert(UsuariosTable.table, {
      UsuariosTable.email: 'test@test.com',
      UsuariosTable.passwordHash: 'hash',
      UsuariosTable.passwordSalt: 'salt',
    });
  });

  tearDown(() => db.close());

  test('sin configurar, la tasa es null', () async {
    expect(await dataSource.obtenerTasaCambioReferencia(), isNull);
  });

  test('establecerTasaCambioReferencia la guarda y se puede leer de vuelta', () async {
    await dataSource.establecerTasaCambioReferencia(60.5);

    expect(await dataSource.obtenerTasaCambioReferencia(), 60.5);
  });

  test('establecer de nuevo actualiza el valor', () async {
    await dataSource.establecerTasaCambioReferencia(60);
    await dataSource.establecerTasaCambioReferencia(61.25);

    expect(await dataSource.obtenerTasaCambioReferencia(), 61.25);
  });
}

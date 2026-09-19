import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wazuu/core/database/app_database.dart';

/// Base de datos SQLite real en memoria (vía `sqflite_common_ffi`), con
/// el mismo esquema y seed que `AppDatabase` — permite probar consultas
/// SQL de verdad en los tests sin necesitar sqlcipher nativo (el tipo
/// `Database` es el mismo, `sqflite_sqlcipher` reexporta
/// `sqflite_common`).
Future<Database> createInMemoryTestDatabase() async {
  sqfliteFfiInit();
  return databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) => AppDatabase.crearEsquema(db),
    ),
  );
}

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'db_schema.dart';
import 'seed/seed_categorias.dart';
import 'seed/seed_reglas_categorizacion.dart';

/// Abre la base de datos SQLite cifrada con sqlcipher y aplica las
/// migraciones (sección 6 de CLAUDE.md). La base de datos local NUNCA
/// se guarda sin cifrar — no es negociable.
abstract final class AppDatabase {
  static Future<Database> open(String passphrase) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDir.path, 'wazuu.db');
    return openDatabase(
      path,
      password: passphrase,
      version: DbSchema.version,
      onCreate: (db, version) => crearEsquema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE ${TransaccionesTable.table}
            ADD COLUMN ${TransaccionesTable.tarjetaUltimos4Digitos} TEXT
          ''');
          final reglasExistentes = await db.query(
            ReglasCategorizacionTable.table,
            limit: 1,
          );
          if (reglasExistentes.isEmpty) {
            await seedReglasCategorizacion(db);
          }
        }
      },
    );
  }

  /// Expuesto (no solo usado vía `onCreate`) para que los tests puedan
  /// levantar el mismo esquema real sobre una base de datos en memoria
  /// (`sqflite_common_ffi`) y probar consultas SQL de verdad, sin
  /// necesitar sqlcipher nativo.
  static Future<void> crearEsquema(Database db) async {
    await db.execute('''
      CREATE TABLE ${UsuariosTable.table} (
        ${UsuariosTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${UsuariosTable.email} TEXT NOT NULL UNIQUE,
        ${UsuariosTable.passwordHash} TEXT NOT NULL,
        ${UsuariosTable.passwordSalt} TEXT NOT NULL,
        ${UsuariosTable.tasaCambioReferencia} REAL,
        ${UsuariosTable.fechaActualizacionTasa} TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${BancosConectadosTable.table} (
        ${BancosConectadosTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${BancosConectadosTable.nombreBanco} TEXT NOT NULL,
        ${BancosConectadosTable.remitenteEmail} TEXT NOT NULL,
        ${BancosConectadosTable.activo} INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE ${TarjetasTable.table} (
        ${TarjetasTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TarjetasTable.apodo} TEXT NOT NULL,
        ${TarjetasTable.ultimos4Digitos} TEXT NOT NULL,
        ${TarjetasTable.tipo} TEXT NOT NULL
          CHECK (${TarjetasTable.tipo} IN ('debito', 'credito')),
        ${TarjetasTable.bancoId} INTEGER NOT NULL
          REFERENCES ${BancosConectadosTable.table}(${BancosConectadosTable.id}),
        ${TarjetasTable.limiteCredito} REAL,
        ${TarjetasTable.fechaCorte} TEXT,
        ${TarjetasTable.fechaPago} TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${CategoriasTable.table} (
        ${CategoriasTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${CategoriasTable.nombre} TEXT NOT NULL,
        ${CategoriasTable.tipo} TEXT NOT NULL
          CHECK (${CategoriasTable.tipo} IN ('gasto', 'ingreso')),
        ${CategoriasTable.color} TEXT NOT NULL,
        ${CategoriasTable.icono} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${ReglasCategorizacionTable.table} (
        ${ReglasCategorizacionTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ReglasCategorizacionTable.palabraClaveComercio} TEXT NOT NULL,
        ${ReglasCategorizacionTable.categoriaId} INTEGER NOT NULL
          REFERENCES ${CategoriasTable.table}(${CategoriasTable.id})
      )
    ''');

    await db.execute('''
      CREATE TABLE ${TransaccionesTable.table} (
        ${TransaccionesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TransaccionesTable.monto} REAL NOT NULL,
        ${TransaccionesTable.moneda} TEXT NOT NULL
          CHECK (${TransaccionesTable.moneda} IN ('DOP', 'USD')),
        ${TransaccionesTable.fecha} TEXT NOT NULL,
        ${TransaccionesTable.comercio} TEXT NOT NULL,
        ${TransaccionesTable.estado} TEXT NOT NULL
          CHECK (${TransaccionesTable.estado} IN ('aprobada', 'declinada')),
        ${TransaccionesTable.tipoTransaccion} TEXT NOT NULL
          CHECK (${TransaccionesTable.tipoTransaccion} IN ('gasto', 'ingreso')),
        ${TransaccionesTable.categoriaId} INTEGER
          REFERENCES ${CategoriasTable.table}(${CategoriasTable.id}),
        ${TransaccionesTable.tarjetaId} INTEGER
          REFERENCES ${TarjetasTable.table}(${TarjetasTable.id}),
        ${TransaccionesTable.bancoId} INTEGER NOT NULL
          REFERENCES ${BancosConectadosTable.table}(${BancosConectadosTable.id}),
        ${TransaccionesTable.emailIdOrigen} TEXT NOT NULL,
        ${TransaccionesTable.hashDedupe} TEXT NOT NULL UNIQUE,
        ${TransaccionesTable.tarjetaUltimos4Digitos} TEXT
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_transacciones_fecha
        ON ${TransaccionesTable.table}(${TransaccionesTable.fecha})
    ''');

    await db.execute('''
      CREATE TABLE ${PresupuestosTable.table} (
        ${PresupuestosTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${PresupuestosTable.categoriaId} INTEGER
          REFERENCES ${CategoriasTable.table}(${CategoriasTable.id}),
        ${PresupuestosTable.montoLimite} REAL NOT NULL,
        ${PresupuestosTable.periodo} TEXT NOT NULL
          CHECK (${PresupuestosTable.periodo} IN ('mensual')),
        ${PresupuestosTable.fechaInicio} TEXT NOT NULL
      )
    ''');

    await seedCategorias(db);
    await seedReglasCategorizacion(db);
  }
}

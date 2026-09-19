import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../../core/database/db_schema.dart';
import '../../domain/entities/local_account.dart';

/// Persistencia de la cuenta local en la tabla `usuarios`, cifrada con
/// sqlcipher (sección 6 de CLAUDE.md). Reemplaza al data source interino
/// de la Fase 2 basado en `flutter_secure_storage`.
///
/// El MVP soporta una sola cuenta local por dispositivo, por eso siempre
/// se opera sobre la primera fila.
class AuthSqlDataSource {
  AuthSqlDataSource(this._db);

  final Database _db;

  Future<LocalAccount?> readAccount() async {
    final rows = await _db.query(UsuariosTable.table, limit: 1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return LocalAccount(
      email: row[UsuariosTable.email]! as String,
      passwordHash: row[UsuariosTable.passwordHash]! as String,
      passwordSalt: row[UsuariosTable.passwordSalt]! as String,
    );
  }

  Future<void> saveAccount(LocalAccount account) async {
    await _db.insert(UsuariosTable.table, {
      UsuariosTable.email: account.email,
      UsuariosTable.passwordHash: account.passwordHash,
      UsuariosTable.passwordSalt: account.passwordSalt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteAccount() => _db.delete(UsuariosTable.table);
}

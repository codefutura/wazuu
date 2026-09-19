import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../../core/database/db_schema.dart';

class UsuarioSettingsSqlDataSource {
  UsuarioSettingsSqlDataSource(this._db);

  final Database _db;

  Future<double?> obtenerTasaCambioReferencia() async {
    final rows = await _db.query(
      UsuariosTable.table,
      columns: [UsuariosTable.tasaCambioReferencia],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return (rows.first[UsuariosTable.tasaCambioReferencia] as num?)
        ?.toDouble();
  }

  /// El MVP soporta una sola cuenta local por dispositivo (ver
  /// `AuthSqlDataSource`), por eso actualiza sin `WHERE` — solo existe
  /// una fila en `usuarios`.
  Future<void> establecerTasaCambioReferencia(double tasa) {
    return _db.update(UsuariosTable.table, {
      UsuariosTable.tasaCambioReferencia: tasa,
      UsuariosTable.fechaActualizacionTasa: DateTime.now().toIso8601String(),
    });
  }
}

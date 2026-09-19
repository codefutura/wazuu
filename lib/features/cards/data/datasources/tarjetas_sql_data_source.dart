import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../../core/database/db_schema.dart';
import '../../domain/entities/tarjeta.dart';

class TarjetasSqlDataSource {
  TarjetasSqlDataSource(this._db);

  final Database _db;

  Future<List<Tarjeta>> obtenerTodas() async {
    final rows = await _db.rawQuery('''
      SELECT t.*, b.${BancosConectadosTable.nombreBanco} AS b_nombre
      FROM ${TarjetasTable.table} t
      INNER JOIN ${BancosConectadosTable.table} b
        ON b.${BancosConectadosTable.id} = t.${TarjetasTable.bancoId}
    ''');
    return rows.map(_fromRow).toList();
  }

  Future<void> crear({
    required String apodo,
    required String ultimos4Digitos,
    required TipoTarjeta tipo,
    required int bancoId,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) {
    return _db.insert(TarjetasTable.table, {
      TarjetasTable.apodo: apodo,
      TarjetasTable.ultimos4Digitos: ultimos4Digitos,
      TarjetasTable.tipo: tipo == TipoTarjeta.credito ? 'credito' : 'debito',
      TarjetasTable.bancoId: bancoId,
      TarjetasTable.limiteCredito: limiteCredito,
      TarjetasTable.fechaCorte: fechaCorte?.toIso8601String(),
      TarjetasTable.fechaPago: fechaPago?.toIso8601String(),
    });
  }

  Future<void> actualizar({
    required int id,
    required String apodo,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) {
    return _db.update(
      TarjetasTable.table,
      {
        TarjetasTable.apodo: apodo,
        TarjetasTable.limiteCredito: limiteCredito,
        TarjetasTable.fechaCorte: fechaCorte?.toIso8601String(),
        TarjetasTable.fechaPago: fechaPago?.toIso8601String(),
      },
      where: '${TarjetasTable.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> eliminar(int id) {
    return _db.delete(
      TarjetasTable.table,
      where: '${TarjetasTable.id} = ?',
      whereArgs: [id],
    );
  }

  Future<Tarjeta?> obtenerPorUltimos4Digitos({
    required int bancoId,
    required String ultimos4Digitos,
  }) async {
    final rows = await _db.rawQuery(
      '''
      SELECT t.*, b.${BancosConectadosTable.nombreBanco} AS b_nombre
      FROM ${TarjetasTable.table} t
      INNER JOIN ${BancosConectadosTable.table} b
        ON b.${BancosConectadosTable.id} = t.${TarjetasTable.bancoId}
      WHERE t.${TarjetasTable.bancoId} = ? AND
            t.${TarjetasTable.ultimos4Digitos} = ?
      LIMIT 1
    ''',
      [bancoId, ultimos4Digitos],
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Tarjeta _fromRow(Map<String, Object?> row) {
    final fechaCorte = row[TarjetasTable.fechaCorte] as String?;
    final fechaPago = row[TarjetasTable.fechaPago] as String?;
    return Tarjeta(
      id: row[TarjetasTable.id]! as int,
      apodo: row[TarjetasTable.apodo]! as String,
      ultimos4Digitos: row[TarjetasTable.ultimos4Digitos]! as String,
      tipo: (row[TarjetasTable.tipo]! as String) == 'credito'
          ? TipoTarjeta.credito
          : TipoTarjeta.debito,
      bancoId: row[TarjetasTable.bancoId]! as int,
      nombreBanco: row['b_nombre']! as String,
      limiteCredito: (row[TarjetasTable.limiteCredito] as num?)?.toDouble(),
      fechaCorte: fechaCorte == null ? null : DateTime.parse(fechaCorte),
      fechaPago: fechaPago == null ? null : DateTime.parse(fechaPago),
    );
  }
}

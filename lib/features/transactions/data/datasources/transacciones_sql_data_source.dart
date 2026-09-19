import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../../core/database/db_schema.dart';
import '../../../../core/domain/estado_transaccion.dart';
import '../../../../core/domain/moneda.dart';
import '../../../../core/domain/tipo_transaccion.dart';
import '../../../categorization/domain/entities/categoria.dart';
import '../../domain/entities/transaccion_huerfana.dart';
import '../../domain/entities/transaccion_registro.dart';

/// `transacciones.fecha` se guarda como texto ISO-8601
/// (`DateTime.toIso8601String()`) — ordena y compara correctamente como
/// texto, así que los filtros de rango son comparaciones de string
/// simples, sin funciones de fecha de SQLite.
class TransaccionesSqlDataSource {
  TransaccionesSqlDataSource(this._db);

  final Database _db;

  Future<void> actualizarCategoria({
    required int transaccionId,
    required int categoriaId,
  }) {
    return _db.update(
      TransaccionesTable.table,
      {TransaccionesTable.categoriaId: categoriaId},
      where: '${TransaccionesTable.id} = ?',
      whereArgs: [transaccionId],
    );
  }

  /// Devuelve `true` si se insertó; `false` si `hashDedupe` ya existía
  /// (`INSERT OR IGNORE`, apoyado en el índice `UNIQUE` del esquema).
  Future<bool> insertar({
    required double monto,
    required Moneda moneda,
    required DateTime fecha,
    required String comercio,
    required EstadoTransaccion estado,
    required TipoTransaccion tipoTransaccion,
    required int categoriaId,
    int? tarjetaId,
    required int bancoId,
    required String emailIdOrigen,
    required String hashDedupe,
    String? tarjetaUltimos4Digitos,
  }) async {
    final id = await _db.insert(TransaccionesTable.table, {
      TransaccionesTable.monto: monto,
      TransaccionesTable.moneda: moneda == Moneda.dop ? 'DOP' : 'USD',
      TransaccionesTable.fecha: fecha.toIso8601String(),
      TransaccionesTable.comercio: comercio,
      TransaccionesTable.estado: estado == EstadoTransaccion.aprobada
          ? 'aprobada'
          : 'declinada',
      TransaccionesTable.tipoTransaccion:
          tipoTransaccion == TipoTransaccion.gasto ? 'gasto' : 'ingreso',
      TransaccionesTable.categoriaId: categoriaId,
      TransaccionesTable.tarjetaId: tarjetaId,
      TransaccionesTable.bancoId: bancoId,
      TransaccionesTable.emailIdOrigen: emailIdOrigen,
      TransaccionesTable.hashDedupe: hashDedupe,
      TransaccionesTable.tarjetaUltimos4Digitos: tarjetaUltimos4Digitos,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    return id != 0;
  }

  /// Vincula retroactivamente transacciones que llegaron antes de que
  /// existiera esta tarjeta (`tarjeta_id` quedó `null` al sincronizar,
  /// sección 6 de CLAUDE.md). Devuelve cuántas se vincularon.
  Future<int> reasignarTarjetaHuerfanas({
    required int bancoId,
    required String ultimos4Digitos,
    required int tarjetaId,
  }) {
    return _db.update(
      TransaccionesTable.table,
      {TransaccionesTable.tarjetaId: tarjetaId},
      where:
          '${TransaccionesTable.bancoId} = ? AND '
          '${TransaccionesTable.tarjetaId} IS NULL AND '
          '${TransaccionesTable.tarjetaUltimos4Digitos} = ?',
      whereArgs: [bancoId, ultimos4Digitos],
    );
  }

  Future<List<TransaccionHuerfana>> obtenerHuerfanasPorBanco(
    int bancoId,
  ) async {
    final filas = await _db.query(
      TransaccionesTable.table,
      columns: [TransaccionesTable.id, TransaccionesTable.emailIdOrigen],
      where:
          '${TransaccionesTable.bancoId} = ? AND '
          '${TransaccionesTable.tarjetaId} IS NULL',
      whereArgs: [bancoId],
    );
    return [
      for (final fila in filas)
        TransaccionHuerfana(
          id: fila[TransaccionesTable.id]! as int,
          emailIdOrigen: fila[TransaccionesTable.emailIdOrigen]! as String,
        ),
    ];
  }

  Future<void> vincularTarjeta({
    required int transaccionId,
    required int tarjetaId,
    required String tarjetaUltimos4Digitos,
  }) {
    return _db.update(
      TransaccionesTable.table,
      {
        TransaccionesTable.tarjetaId: tarjetaId,
        TransaccionesTable.tarjetaUltimos4Digitos: tarjetaUltimos4Digitos,
      },
      where: '${TransaccionesTable.id} = ?',
      whereArgs: [transaccionId],
    );
  }

  Future<List<TransaccionRegistro>> obtener({
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    int? tarjetaId,
  }) async {
    final where = <String>[];
    final args = <Object?>[];

    if (desde != null) {
      where.add('t.${TransaccionesTable.fecha} >= ?');
      args.add(desde.toIso8601String());
    }
    if (hasta != null) {
      where.add('t.${TransaccionesTable.fecha} <= ?');
      args.add(hasta.toIso8601String());
    }
    if (categoriaId != null) {
      where.add('t.${TransaccionesTable.categoriaId} = ?');
      args.add(categoriaId);
    }
    if (tarjetaId != null) {
      where.add('t.${TransaccionesTable.tarjetaId} = ?');
      args.add(tarjetaId);
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final rows = await _db.rawQuery('''
      SELECT
        t.${TransaccionesTable.id} AS t_id,
        t.${TransaccionesTable.monto} AS t_monto,
        t.${TransaccionesTable.moneda} AS t_moneda,
        t.${TransaccionesTable.fecha} AS t_fecha,
        t.${TransaccionesTable.comercio} AS t_comercio,
        t.${TransaccionesTable.estado} AS t_estado,
        t.${TransaccionesTable.tipoTransaccion} AS t_tipo,
        t.${TransaccionesTable.tarjetaId} AS t_tarjeta_id,
        t.${TransaccionesTable.bancoId} AS t_banco_id,
        c.${CategoriasTable.id} AS c_id,
        c.${CategoriasTable.nombre} AS c_nombre,
        c.${CategoriasTable.tipo} AS c_tipo,
        c.${CategoriasTable.color} AS c_color,
        c.${CategoriasTable.icono} AS c_icono,
        tj.${TarjetasTable.apodo} AS tj_apodo,
        tj.${TarjetasTable.ultimos4Digitos} AS tj_ultimos4,
        b.${BancosConectadosTable.nombreBanco} AS b_nombre
      FROM ${TransaccionesTable.table} t
      INNER JOIN ${CategoriasTable.table} c
        ON c.${CategoriasTable.id} = t.${TransaccionesTable.categoriaId}
      INNER JOIN ${BancosConectadosTable.table} b
        ON b.${BancosConectadosTable.id} = t.${TransaccionesTable.bancoId}
      LEFT JOIN ${TarjetasTable.table} tj
        ON tj.${TarjetasTable.id} = t.${TransaccionesTable.tarjetaId}
      $whereClause
      ORDER BY t.${TransaccionesTable.fecha} DESC
    ''', args);

    return rows.map(_fromRow).toList();
  }

  TransaccionRegistro _fromRow(Map<String, Object?> row) {
    return TransaccionRegistro(
      id: row['t_id']! as int,
      monto: (row['t_monto']! as num).toDouble(),
      moneda: (row['t_moneda']! as String) == 'DOP' ? Moneda.dop : Moneda.usd,
      fecha: DateTime.parse(row['t_fecha']! as String),
      comercio: row['t_comercio']! as String,
      estado: (row['t_estado']! as String) == 'aprobada'
          ? EstadoTransaccion.aprobada
          : EstadoTransaccion.declinada,
      tipoTransaccion: (row['t_tipo']! as String) == 'gasto'
          ? TipoTransaccion.gasto
          : TipoTransaccion.ingreso,
      categoria: Categoria(
        id: row['c_id']! as int,
        nombre: row['c_nombre']! as String,
        tipo: (row['c_tipo']! as String) == 'gasto'
            ? TipoTransaccion.gasto
            : TipoTransaccion.ingreso,
        color: row['c_color']! as String,
        icono: row['c_icono']! as String,
      ),
      bancoId: row['t_banco_id']! as int,
      nombreBanco: row['b_nombre']! as String,
      tarjetaId: row['t_tarjeta_id'] as int?,
      tarjetaApodo: row['tj_apodo'] as String?,
      tarjetaUltimos4Digitos: row['tj_ultimos4'] as String?,
    );
  }
}

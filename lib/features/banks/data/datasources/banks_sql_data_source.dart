import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../../core/database/db_schema.dart';
import '../../domain/entities/banco_conectado.dart';
import '../../domain/entities/bank_option.dart';

/// Persistencia de los bancos conectados en la tabla `bancos_conectados`
/// (sección 6 de CLAUDE.md).
class BanksSqlDataSource {
  BanksSqlDataSource(this._db);

  final Database _db;

  /// Actualiza en vez de recrear filas: `tarjetas.banco_id` y
  /// `transacciones.banco_id` referencian estos `id`, borrarlos y
  /// reinsertarlos los dejaría huérfanos. Un banco que se desmarca
  /// queda con `activo = 0` en vez de eliminarse.
  Future<void> replaceConnected(List<BankOption> banks) async {
    final seleccionados = banks.map((b) => b.name).toSet();
    final existentes = await _db.query(BancosConectadosTable.table);
    final nombresExistentes = existentes
        .map((row) => row[BancosConectadosTable.nombreBanco] as String)
        .toSet();

    final batch = _db.batch();
    for (final bank in banks) {
      if (nombresExistentes.contains(bank.name)) {
        // También refresca `remitente_email`: si el catálogo corrige un
        // remitente (ej. el ajuste de la Fase de sincronización), un
        // banco ya conectado no debe quedar con el valor viejo para
        // siempre.
        batch.update(
          BancosConectadosTable.table,
          {
            BancosConectadosTable.activo: 1,
            BancosConectadosTable.remitenteEmail: bank.senderEmail,
          },
          where: '${BancosConectadosTable.nombreBanco} = ?',
          whereArgs: [bank.name],
        );
      } else {
        batch.insert(BancosConectadosTable.table, {
          BancosConectadosTable.nombreBanco: bank.name,
          BancosConectadosTable.remitenteEmail: bank.senderEmail,
          BancosConectadosTable.activo: 1,
        });
      }
    }
    for (final row in existentes) {
      final nombre = row[BancosConectadosTable.nombreBanco] as String;
      if (!seleccionados.contains(nombre)) {
        batch.update(
          BancosConectadosTable.table,
          {BancosConectadosTable.activo: 0},
          where: '${BancosConectadosTable.id} = ?',
          whereArgs: [row[BancosConectadosTable.id]],
        );
      }
    }
    await batch.commit(noResult: true);
  }

  Future<Set<String>> readConnectedNames() async {
    final rows = await _db.query(
      BancosConectadosTable.table,
      where: '${BancosConectadosTable.activo} = 1',
    );
    return rows
        .map((row) => row[BancosConectadosTable.nombreBanco]! as String)
        .toSet();
  }

  Future<List<BancoConectado>> readConnectedRows() async {
    final rows = await _db.query(
      BancosConectadosTable.table,
      where: '${BancosConectadosTable.activo} = 1',
    );
    return rows
        .map(
          (row) => BancoConectado(
            id: row[BancosConectadosTable.id]! as int,
            nombreBanco: row[BancosConectadosTable.nombreBanco]! as String,
            remitenteEmail:
                row[BancosConectadosTable.remitenteEmail]! as String,
          ),
        )
        .toList();
  }
}

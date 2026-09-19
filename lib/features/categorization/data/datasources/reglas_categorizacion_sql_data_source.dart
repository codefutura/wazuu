import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../../core/database/db_schema.dart';
import '../../domain/entities/regla_categorizacion.dart';

class ReglasCategorizacionSqlDataSource {
  ReglasCategorizacionSqlDataSource(this._db);

  final Database _db;

  Future<List<ReglaCategorizacion>> obtenerTodas() async {
    final rows = await _db.query(ReglasCategorizacionTable.table);
    return rows
        .map(
          (row) => ReglaCategorizacion(
            id: row[ReglasCategorizacionTable.id]! as int,
            palabraClaveComercio:
                row[ReglasCategorizacionTable.palabraClaveComercio]!
                    as String,
            categoriaId: row[ReglasCategorizacionTable.categoriaId]! as int,
          ),
        )
        .toList();
  }

  Future<void> upsert({
    required String palabraClaveComercio,
    required int categoriaId,
  }) async {
    final rows = await _db.query(ReglasCategorizacionTable.table);
    final normalizada = palabraClaveComercio.toUpperCase();

    Map<String, Object?>? existente;
    for (final row in rows) {
      final actual =
          row[ReglasCategorizacionTable.palabraClaveComercio]! as String;
      if (actual.toUpperCase() == normalizada) {
        existente = row;
        break;
      }
    }

    if (existente == null) {
      await _db.insert(ReglasCategorizacionTable.table, {
        ReglasCategorizacionTable.palabraClaveComercio: palabraClaveComercio,
        ReglasCategorizacionTable.categoriaId: categoriaId,
      });
    } else {
      await _db.update(
        ReglasCategorizacionTable.table,
        {ReglasCategorizacionTable.categoriaId: categoriaId},
        where: '${ReglasCategorizacionTable.id} = ?',
        whereArgs: [existente[ReglasCategorizacionTable.id]],
      );
    }
  }
}

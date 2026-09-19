import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../../core/database/db_schema.dart';
import '../../../../core/domain/tipo_transaccion.dart';
import '../../domain/entities/categoria.dart';

class CategoriasSqlDataSource {
  CategoriasSqlDataSource(this._db);

  final Database _db;

  Future<List<Categoria>> obtenerTodas() async {
    final rows = await _db.query(CategoriasTable.table);
    return rows.map(_fromRow).toList();
  }

  Categoria _fromRow(Map<String, Object?> row) {
    return Categoria(
      id: row[CategoriasTable.id]! as int,
      nombre: row[CategoriasTable.nombre]! as String,
      tipo: (row[CategoriasTable.tipo]! as String) == 'gasto'
          ? TipoTransaccion.gasto
          : TipoTransaccion.ingreso,
      color: row[CategoriasTable.color]! as String,
      icono: row[CategoriasTable.icono]! as String,
    );
  }
}

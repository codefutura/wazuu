import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../../core/database/db_schema.dart';
import '../../domain/entities/presupuesto.dart';

class PresupuestosSqlDataSource {
  PresupuestosSqlDataSource(this._db);

  final Database _db;

  Future<List<Presupuesto>> obtenerTodos() async {
    final rows = await _db.query(PresupuestosTable.table);
    return rows.map(_fromRow).toList();
  }

  Future<void> crear({
    required int? categoriaId,
    required double montoLimite,
    required DateTime fechaInicio,
  }) {
    return _db.insert(PresupuestosTable.table, {
      PresupuestosTable.categoriaId: categoriaId,
      PresupuestosTable.montoLimite: montoLimite,
      PresupuestosTable.periodo: 'mensual',
      PresupuestosTable.fechaInicio: fechaInicio.toIso8601String(),
    });
  }

  Future<void> actualizarMonto({required int id, required double montoLimite}) {
    return _db.update(
      PresupuestosTable.table,
      {PresupuestosTable.montoLimite: montoLimite},
      where: '${PresupuestosTable.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> eliminar(int id) {
    return _db.delete(
      PresupuestosTable.table,
      where: '${PresupuestosTable.id} = ?',
      whereArgs: [id],
    );
  }

  Presupuesto _fromRow(Map<String, Object?> row) {
    return Presupuesto(
      id: row[PresupuestosTable.id]! as int,
      categoriaId: row[PresupuestosTable.categoriaId] as int?,
      montoLimite: (row[PresupuestosTable.montoLimite]! as num).toDouble(),
      fechaInicio: DateTime.parse(row[PresupuestosTable.fechaInicio]! as String),
    );
  }
}

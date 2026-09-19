import 'package:sqflite_sqlcipher/sqflite.dart';

import '../db_schema.dart';

/// Categorías base (ver sección 8 de CLAUDE.md). Se insertan una sola
/// vez al crear la base de datos para que `transacciones` y
/// `reglas_categorizacion` tengan a qué apuntar desde el primer
/// arranque, incluso antes de que exista el motor de categorización
/// (Fase 6).
Future<void> seedCategorias(Database db) async {
  const gastos = [
    ('Compras', '#0F766E', 'shopping_bag'),
    ('Alimentos', '#F59E0B', 'restaurant'),
    ('Finanzas', '#64748B', 'account_balance'),
    ('Servicios', '#22C55E', 'bolt'),
    ('Transporte', '#FB7185', 'directions_car'),
    ('Suscripciones', '#0F766E', 'subscriptions'),
    ('Otro', '#64748B', 'category'),
  ];
  const ingresos = [
    ('Nómina', '#22C55E', 'payments'),
    ('Transferencia', '#0F766E', 'swap_horiz'),
    ('Otro ingreso', '#64748B', 'attach_money'),
  ];

  final batch = db.batch();
  for (final (nombre, color, icono) in gastos) {
    batch.insert(CategoriasTable.table, {
      CategoriasTable.nombre: nombre,
      CategoriasTable.tipo: 'gasto',
      CategoriasTable.color: color,
      CategoriasTable.icono: icono,
    });
  }
  for (final (nombre, color, icono) in ingresos) {
    batch.insert(CategoriasTable.table, {
      CategoriasTable.nombre: nombre,
      CategoriasTable.tipo: 'ingreso',
      CategoriasTable.color: color,
      CategoriasTable.icono: icono,
    });
  }
  await batch.commit(noResult: true);
}

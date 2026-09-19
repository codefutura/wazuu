import 'package:sqflite_sqlcipher/sqflite.dart';

import '../db_schema.dart';

/// Reglas de categorización iniciales para comercios y servicios muy
/// comunes en República Dominicana (sección 8 de CLAUDE.md) — un punto
/// de partida razonable para que no todo caiga en "Otro" desde el
/// primer correo. El usuario puede editar o reemplazar cualquiera de
/// estas recategorizando con un tap, igual que una regla aprendida.
///
/// Cada palabra clave es una coincidencia parcial contra el texto del
/// comercio ya en mayúsculas (`CategorizationEngine.categorizar`), así
/// que basta con el nombre de marca reconocible en el descriptor de la
/// transacción, sin intentar adivinar el formato exacto de cada banco.
const _reglasPorDefecto = <(String palabraClave, String categoria)>[
  ('UBER', 'Transporte'),
  ('NETFLIX', 'Suscripciones'),
  ('SPOTIFY', 'Suscripciones'),
  ('DISNEY', 'Suscripciones'),
  ('YOUTUBE', 'Suscripciones'),
  ('HBO', 'Suscripciones'),
  ('APPLE.COM', 'Suscripciones'),
  ('SUPERMERCADO NACIONAL', 'Alimentos'),
  ('LA SIRENA', 'Alimentos'),
  ('JUMBO', 'Alimentos'),
  ('MCDONALD', 'Alimentos'),
  ('DOMINO', 'Alimentos'),
  ('STARBUCKS', 'Alimentos'),
  ('EDESUR', 'Servicios'),
  ('EDENORTE', 'Servicios'),
  ('EDEESTE', 'Servicios'),
  ('CLARO', 'Servicios'),
  ('ALTICE', 'Servicios'),
  ('AMAZON', 'Compras'),
  ('PRICESMART', 'Compras'),
];

Future<void> seedReglasCategorizacion(Database db) async {
  final categorias = await db.query(CategoriasTable.table);
  final idPorNombre = {
    for (final fila in categorias)
      fila[CategoriasTable.nombre] as String: fila[CategoriasTable.id] as int,
  };

  final batch = db.batch();
  for (final (palabraClave, nombreCategoria) in _reglasPorDefecto) {
    final categoriaId = idPorNombre[nombreCategoria];
    if (categoriaId == null) continue;
    batch.insert(ReglasCategorizacionTable.table, {
      ReglasCategorizacionTable.palabraClaveComercio: palabraClave,
      ReglasCategorizacionTable.categoriaId: categoriaId,
    });
  }
  await batch.commit(noResult: true);
}

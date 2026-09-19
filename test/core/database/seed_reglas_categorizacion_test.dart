import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wazuu/core/database/db_schema.dart';

import '../../helpers/in_memory_database.dart';

/// `crearEsquema` (usado tanto por `AppDatabase.open` como por este
/// helper de tests) ya deja precargadas algunas reglas de
/// categorización comunes en RD (sección 8 de CLAUDE.md) — este test
/// confirma que el seed corrió y apunta a las categorías correctas.
void main() {
  late Database db;

  setUp(() async {
    db = await createInMemoryTestDatabase();
  });

  tearDown(() => db.close());

  Future<String?> categoriaDe(String palabraClave) async {
    final filas = await db.rawQuery(
      '''
      SELECT c.${CategoriasTable.nombre} AS nombre
      FROM ${ReglasCategorizacionTable.table} r
      INNER JOIN ${CategoriasTable.table} c
        ON c.${CategoriasTable.id} = r.${ReglasCategorizacionTable.categoriaId}
      WHERE r.${ReglasCategorizacionTable.palabraClaveComercio} = ?
    ''',
      [palabraClave],
    );
    return filas.isEmpty ? null : filas.single['nombre'] as String;
  }

  test('precarga reglas comunes al crear el esquema', () async {
    final total = await db.query(ReglasCategorizacionTable.table);
    expect(total, isNotEmpty);
  });

  test('UBER cae en Transporte', () async {
    expect(await categoriaDe('UBER'), 'Transporte');
  });

  test('NETFLIX cae en Suscripciones', () async {
    expect(await categoriaDe('NETFLIX'), 'Suscripciones');
  });

  test('SUPERMERCADO NACIONAL cae en Alimentos', () async {
    expect(await categoriaDe('SUPERMERCADO NACIONAL'), 'Alimentos');
  });

  test('CLARO cae en Servicios', () async {
    expect(await categoriaDe('CLARO'), 'Servicios');
  });

  test('AMAZON cae en Compras', () async {
    expect(await categoriaDe('AMAZON'), 'Compras');
  });
}

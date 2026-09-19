import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wazuu/core/database/db_schema.dart';
import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/transactions/data/datasources/transacciones_sql_data_source.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late Database db;
  late TransaccionesSqlDataSource dataSource;
  late int bancoId;
  late int tarjetaId;
  late int categoriaComprasId;
  late int categoriaNominaId;

  setUp(() async {
    db = await createInMemoryTestDatabase();
    dataSource = TransaccionesSqlDataSource(db);

    bancoId = await db.insert(BancosConectadosTable.table, {
      BancosConectadosTable.nombreBanco: 'BHD',
      BancosConectadosTable.remitenteEmail: 'alertas@bhd.com.do',
      BancosConectadosTable.activo: 1,
    });

    tarjetaId = await db.insert(TarjetasTable.table, {
      TarjetasTable.apodo: 'Visa Débito',
      TarjetasTable.ultimos4Digitos: '5472',
      TarjetasTable.tipo: 'debito',
      TarjetasTable.bancoId: bancoId,
    });

    final categorias = await db.query(CategoriasTable.table);
    categoriaComprasId =
        categorias.firstWhere((c) => c[CategoriasTable.nombre] == 'Compras')[CategoriasTable.id]!
            as int;
    categoriaNominaId =
        categorias.firstWhere((c) => c[CategoriasTable.nombre] == 'Nómina')[CategoriasTable.id]!
            as int;
  });

  tearDown(() => db.close());

  Future<int> insertarTransaccion({
    required double monto,
    required String moneda,
    required DateTime fecha,
    required String comercio,
    required String estado,
    required String tipo,
    required int categoriaId,
    int? tarjetaIdFk,
    String emailIdOrigen = 'email-1',
    String? hashDedupe,
  }) {
    return db.insert(TransaccionesTable.table, {
      TransaccionesTable.monto: monto,
      TransaccionesTable.moneda: moneda,
      TransaccionesTable.fecha: fecha.toIso8601String(),
      TransaccionesTable.comercio: comercio,
      TransaccionesTable.estado: estado,
      TransaccionesTable.tipoTransaccion: tipo,
      TransaccionesTable.categoriaId: categoriaId,
      TransaccionesTable.tarjetaId: tarjetaIdFk,
      TransaccionesTable.bancoId: bancoId,
      TransaccionesTable.emailIdOrigen: emailIdOrigen,
      TransaccionesTable.hashDedupe: hashDedupe ?? 'hash-$emailIdOrigen',
    });
  }

  test('trae una transacción con su categoría y tarjeta resueltas', () async {
    await insertarTransaccion(
      monto: 185.14,
      moneda: 'DOP',
      fecha: DateTime(2026, 9, 15),
      comercio: 'CFN FERRECENTRO',
      estado: 'aprobada',
      tipo: 'gasto',
      categoriaId: categoriaComprasId,
      tarjetaIdFk: tarjetaId,
    );

    final resultado = await dataSource.obtener();

    expect(resultado, hasLength(1));
    final t = resultado.single;
    expect(t.monto, 185.14);
    expect(t.moneda, Moneda.dop);
    expect(t.comercio, 'CFN FERRECENTRO');
    expect(t.estado, EstadoTransaccion.aprobada);
    expect(t.tipoTransaccion, TipoTransaccion.gasto);
    expect(t.categoria.nombre, 'Compras');
    expect(t.tarjetaApodo, 'Visa Débito');
    expect(t.tarjetaUltimos4Digitos, '5472');
  });

  test('una transacción sin tarjeta asociada trae tarjetaApodo null', () async {
    await insertarTransaccion(
      monto: 50,
      moneda: 'USD',
      fecha: DateTime(2026, 9, 15),
      comercio: 'Comercio sin tarjeta',
      estado: 'aprobada',
      tipo: 'gasto',
      categoriaId: categoriaComprasId,
    );

    final resultado = await dataSource.obtener();

    expect(resultado.single.tarjetaApodo, isNull);
    expect(resultado.single.tarjetaId, isNull);
  });

  test('filtra por rango de fechas', () async {
    await insertarTransaccion(
      monto: 100,
      moneda: 'DOP',
      fecha: DateTime(2026, 8, 1),
      comercio: 'Fuera de rango',
      estado: 'aprobada',
      tipo: 'gasto',
      categoriaId: categoriaComprasId,
      emailIdOrigen: 'e1',
    );
    await insertarTransaccion(
      monto: 200,
      moneda: 'DOP',
      fecha: DateTime(2026, 9, 15),
      comercio: 'Dentro de rango',
      estado: 'aprobada',
      tipo: 'gasto',
      categoriaId: categoriaComprasId,
      emailIdOrigen: 'e2',
    );

    final resultado = await dataSource.obtener(
      desde: DateTime(2026, 9, 1),
      hasta: DateTime(2026, 9, 30),
    );

    expect(resultado, hasLength(1));
    expect(resultado.single.comercio, 'Dentro de rango');
  });

  test('filtra por categoría y por tarjeta', () async {
    await insertarTransaccion(
      monto: 100,
      moneda: 'DOP',
      fecha: DateTime(2026, 9, 5),
      comercio: 'Nómina',
      estado: 'aprobada',
      tipo: 'ingreso',
      categoriaId: categoriaNominaId,
      emailIdOrigen: 'e1',
    );
    await insertarTransaccion(
      monto: 200,
      moneda: 'DOP',
      fecha: DateTime(2026, 9, 6),
      comercio: 'Compra',
      estado: 'aprobada',
      tipo: 'gasto',
      categoriaId: categoriaComprasId,
      tarjetaIdFk: tarjetaId,
      emailIdOrigen: 'e2',
    );

    final porCategoria = await dataSource.obtener(categoriaId: categoriaNominaId);
    expect(porCategoria, hasLength(1));
    expect(porCategoria.single.comercio, 'Nómina');

    final porTarjeta = await dataSource.obtener(tarjetaId: tarjetaId);
    expect(porTarjeta, hasLength(1));
    expect(porTarjeta.single.comercio, 'Compra');
  });

  test('ordena de la más reciente a la más antigua', () async {
    await insertarTransaccion(
      monto: 1,
      moneda: 'DOP',
      fecha: DateTime(2026, 9, 1),
      comercio: 'Primera',
      estado: 'aprobada',
      tipo: 'gasto',
      categoriaId: categoriaComprasId,
      emailIdOrigen: 'e1',
    );
    await insertarTransaccion(
      monto: 2,
      moneda: 'DOP',
      fecha: DateTime(2026, 9, 20),
      comercio: 'Más reciente',
      estado: 'aprobada',
      tipo: 'gasto',
      categoriaId: categoriaComprasId,
      emailIdOrigen: 'e2',
    );

    final resultado = await dataSource.obtener();

    expect(resultado.first.comercio, 'Más reciente');
    expect(resultado.last.comercio, 'Primera');
  });

  test('insertar guarda una transacción nueva', () async {
    final insertada = await dataSource.insertar(
      monto: 185.14,
      moneda: Moneda.dop,
      fecha: DateTime(2026, 9, 15),
      comercio: 'CFN FERRECENTRO',
      estado: EstadoTransaccion.aprobada,
      tipoTransaccion: TipoTransaccion.gasto,
      categoriaId: categoriaComprasId,
      tarjetaId: tarjetaId,
      bancoId: bancoId,
      emailIdOrigen: 'msg-1',
      hashDedupe: 'hash-1',
    );

    expect(insertada, isTrue);
    final resultado = await dataSource.obtener();
    expect(resultado, hasLength(1));
    expect(resultado.single.comercio, 'CFN FERRECENTRO');
  });

  test('insertar con el mismo hashDedupe no duplica (deduplicación real)', () async {
    final primera = await dataSource.insertar(
      monto: 185.14,
      moneda: Moneda.dop,
      fecha: DateTime(2026, 9, 15),
      comercio: 'CFN FERRECENTRO',
      estado: EstadoTransaccion.aprobada,
      tipoTransaccion: TipoTransaccion.gasto,
      categoriaId: categoriaComprasId,
      bancoId: bancoId,
      emailIdOrigen: 'msg-1',
      hashDedupe: 'mismo-hash',
    );
    final segunda = await dataSource.insertar(
      monto: 999,
      moneda: Moneda.usd,
      fecha: DateTime(2026, 9, 20),
      comercio: 'Otro comercio',
      estado: EstadoTransaccion.aprobada,
      tipoTransaccion: TipoTransaccion.ingreso,
      categoriaId: categoriaNominaId,
      bancoId: bancoId,
      emailIdOrigen: 'msg-2',
      hashDedupe: 'mismo-hash',
    );

    expect(primera, isTrue);
    expect(segunda, isFalse);
    expect(await dataSource.obtener(), hasLength(1));
  });

  test('insertar sin tarjeta asociada guarda tarjetaId null', () async {
    await dataSource.insertar(
      monto: 50,
      moneda: Moneda.usd,
      fecha: DateTime(2026, 9, 15),
      comercio: 'Comercio sin tarjeta conocida',
      estado: EstadoTransaccion.aprobada,
      tipoTransaccion: TipoTransaccion.gasto,
      categoriaId: categoriaComprasId,
      bancoId: bancoId,
      emailIdOrigen: 'msg-3',
      hashDedupe: 'hash-3',
    );

    final resultado = (await dataSource.obtener()).single;
    expect(resultado.tarjetaId, isNull);
  });

  test(
    'insertar sin tarjeta conocida igual guarda los últimos 4 dígitos '
    'crudos (para poder vincularla después)',
    () async {
      await dataSource.insertar(
        monto: 50,
        moneda: Moneda.usd,
        fecha: DateTime(2026, 9, 15),
        comercio: 'Comercio con tarjeta nueva',
        estado: EstadoTransaccion.aprobada,
        tipoTransaccion: TipoTransaccion.gasto,
        categoriaId: categoriaComprasId,
        bancoId: bancoId,
        emailIdOrigen: 'msg-4',
        hashDedupe: 'hash-4',
        tarjetaUltimos4Digitos: '2319',
      );

      final filas = await db.query(TransaccionesTable.table);
      expect(
        filas.single[TransaccionesTable.tarjetaUltimos4Digitos],
        '2319',
      );
    },
  );

  group('reasignarTarjetaHuerfanas', () {
    test(
      'vincula transacciones huérfanas que calzan banco + últimos 4',
      () async {
        await dataSource.insertar(
          monto: 50,
          moneda: Moneda.dop,
          fecha: DateTime(2026, 9, 15),
          comercio: 'Compra antes de tener la tarjeta',
          estado: EstadoTransaccion.aprobada,
          tipoTransaccion: TipoTransaccion.gasto,
          categoriaId: categoriaComprasId,
          bancoId: bancoId,
          emailIdOrigen: 'msg-5',
          hashDedupe: 'hash-5',
          tarjetaUltimos4Digitos: '2319',
        );
        final nuevaTarjetaId = await db.insert(TarjetasTable.table, {
          TarjetasTable.apodo: 'Visa Nueva',
          TarjetasTable.ultimos4Digitos: '2319',
          TarjetasTable.tipo: 'debito',
          TarjetasTable.bancoId: bancoId,
        });

        final vinculadas = await dataSource.reasignarTarjetaHuerfanas(
          bancoId: bancoId,
          ultimos4Digitos: '2319',
          tarjetaId: nuevaTarjetaId,
        );

        expect(vinculadas, 1);
        final resultado = (await dataSource.obtener()).single;
        expect(resultado.tarjetaId, nuevaTarjetaId);
      },
    );

    test(
      'no toca transacciones ya vinculadas a otra tarjeta, ni de otro banco '
      'o con otros últimos 4 dígitos',
      () async {
        await dataSource.insertar(
          monto: 1,
          moneda: Moneda.dop,
          fecha: DateTime(2026, 9, 1),
          comercio: 'Ya vinculada',
          estado: EstadoTransaccion.aprobada,
          tipoTransaccion: TipoTransaccion.gasto,
          categoriaId: categoriaComprasId,
          tarjetaId: tarjetaId,
          bancoId: bancoId,
          emailIdOrigen: 'msg-6',
          hashDedupe: 'hash-6',
          tarjetaUltimos4Digitos: '2319',
        );
        await dataSource.insertar(
          monto: 2,
          moneda: Moneda.dop,
          fecha: DateTime(2026, 9, 2),
          comercio: 'Otros últimos 4',
          estado: EstadoTransaccion.aprobada,
          tipoTransaccion: TipoTransaccion.gasto,
          categoriaId: categoriaComprasId,
          bancoId: bancoId,
          emailIdOrigen: 'msg-7',
          hashDedupe: 'hash-7',
          tarjetaUltimos4Digitos: '0000',
        );

        final vinculadas = await dataSource.reasignarTarjetaHuerfanas(
          bancoId: bancoId,
          ultimos4Digitos: '2319',
          tarjetaId: 999,
        );

        expect(vinculadas, 0);
      },
    );
  });
}

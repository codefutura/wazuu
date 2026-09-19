import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/categorization/domain/categorization_engine.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/features/categorization/domain/entities/regla_categorizacion.dart';
import 'package:wazuu/features/categorization/domain/repositories/categorias_repository.dart';
import 'package:wazuu/features/categorization/domain/repositories/reglas_categorizacion_repository.dart';

class _FakeCategoriasRepository implements CategoriasRepository {
  _FakeCategoriasRepository(this._categorias);

  final List<Categoria> _categorias;

  @override
  Future<List<Categoria>> obtenerTodas() async => _categorias;

  @override
  Future<Categoria> obtenerCategoriaOtro(TipoTransaccion tipo) async {
    final nombre = tipo == TipoTransaccion.gasto ? 'Otro' : 'Otro ingreso';
    return _categorias.firstWhere((c) => c.nombre == nombre && c.tipo == tipo);
  }
}

class _FakeReglasCategorizacionRepository
    implements ReglasCategorizacionRepository {
  final List<ReglaCategorizacion> _reglas = [];
  int _nextId = 1;

  @override
  Future<List<ReglaCategorizacion>> obtenerTodas() async =>
      List.unmodifiable(_reglas);

  @override
  Future<void> upsert({
    required String palabraClaveComercio,
    required int categoriaId,
  }) async {
    final normalizada = palabraClaveComercio.toUpperCase();
    final index = _reglas.indexWhere(
      (r) => r.palabraClaveComercio.toUpperCase() == normalizada,
    );
    final regla = ReglaCategorizacion(
      id: index == -1 ? _nextId++ : _reglas[index].id,
      palabraClaveComercio: palabraClaveComercio,
      categoriaId: categoriaId,
    );
    if (index == -1) {
      _reglas.add(regla);
    } else {
      _reglas[index] = regla;
    }
  }
}

void main() {
  const alimentos = Categoria(
    id: 2,
    nombre: 'Alimentos',
    tipo: TipoTransaccion.gasto,
    color: '#F59E0B',
    icono: 'restaurant',
  );
  const otro = Categoria(
    id: 7,
    nombre: 'Otro',
    tipo: TipoTransaccion.gasto,
    color: '#64748B',
    icono: 'category',
  );
  const otroIngreso = Categoria(
    id: 10,
    nombre: 'Otro ingreso',
    tipo: TipoTransaccion.ingreso,
    color: '#64748B',
    icono: 'attach_money',
  );

  late _FakeCategoriasRepository categorias;
  late _FakeReglasCategorizacionRepository reglas;
  late CategorizationEngine engine;

  setUp(() {
    categorias = _FakeCategoriasRepository([alimentos, otro, otroIngreso]);
    reglas = _FakeReglasCategorizacionRepository();
    engine = CategorizationEngine(categorias, reglas);
  });

  test('sin reglas, cae en "Otro" para un gasto', () async {
    final resultado = await engine.categorizar(
      comercio: 'CFN FERRECENTRO',
      tipo: TipoTransaccion.gasto,
    );
    expect(resultado, otro);
  });

  test('sin reglas, cae en "Otro ingreso" para un ingreso', () async {
    final resultado = await engine.categorizar(
      comercio: 'Transferencia recibida',
      tipo: TipoTransaccion.ingreso,
    );
    expect(resultado, otroIngreso);
  });

  test('una regla que calza asigna esa categoría', () async {
    await reglas.upsert(palabraClaveComercio: 'FERRECENTRO', categoriaId: alimentos.id);

    final resultado = await engine.categorizar(
      comercio: 'CFN FERRECENTRO',
      tipo: TipoTransaccion.gasto,
    );
    expect(resultado, alimentos);
  });

  test('ignora una regla de un tipo incompatible', () async {
    // Regla de gasto, pero se pide categorizar un ingreso — no debe
    // aplicar aunque el texto calce.
    await reglas.upsert(palabraClaveComercio: 'FERRECENTRO', categoriaId: alimentos.id);

    final resultado = await engine.categorizar(
      comercio: 'FERRECENTRO',
      tipo: TipoTransaccion.ingreso,
    );
    expect(resultado, otroIngreso);
  });

  test(
    'recategorizar manualmente crea una regla que descarta el código '
    'de referencia después del "*"',
    () async {
      await engine.aprenderDeRecategorizacion(
        comercio: 'FACEBK *ARQPC7AZK4',
        categoriaId: alimentos.id,
      );

      final aprendidas = await reglas.obtenerTodas();
      expect(aprendidas, hasLength(1));
      expect(aprendidas.single.palabraClaveComercio, 'FACEBK');

      // Una transacción futura del mismo comercio, con otro código de
      // referencia, debe categorizarse igual gracias a la regla.
      final resultado = await engine.categorizar(
        comercio: 'FACEBK *B7X2N9QP1',
        tipo: TipoTransaccion.gasto,
      );
      expect(resultado, alimentos);
    },
  );

  test('recategorizar el mismo comercio actualiza la regla en vez de duplicarla', () async {
    await engine.aprenderDeRecategorizacion(
      comercio: 'CFN FERRECENTRO',
      categoriaId: otro.id,
    );
    await engine.aprenderDeRecategorizacion(
      comercio: 'cfn ferrecentro',
      categoriaId: alimentos.id,
    );

    final aprendidas = await reglas.obtenerTodas();
    expect(aprendidas, hasLength(1));
    expect(aprendidas.single.categoriaId, alimentos.id);
  });
}

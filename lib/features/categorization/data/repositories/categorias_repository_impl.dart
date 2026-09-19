import '../../../../core/domain/tipo_transaccion.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/repositories/categorias_repository.dart';
import '../datasources/categorias_sql_data_source.dart';

class CategoriasRepositoryImpl implements CategoriasRepository {
  CategoriasRepositoryImpl(this._dataSource);

  final CategoriasSqlDataSource _dataSource;

  @override
  Future<List<Categoria>> obtenerTodas() => _dataSource.obtenerTodas();

  @override
  Future<Categoria> obtenerCategoriaOtro(TipoTransaccion tipo) async {
    final nombre = tipo == TipoTransaccion.gasto ? 'Otro' : 'Otro ingreso';
    final categorias = await _dataSource.obtenerTodas();
    for (final categoria in categorias) {
      if (categoria.nombre == nombre && categoria.tipo == tipo) {
        return categoria;
      }
    }
    throw StateError(
      'Categoría de respaldo "$nombre" no existe — revisa el seed de la '
      'Fase 3 (seed_categorias.dart).',
    );
  }
}

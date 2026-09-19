import '../../domain/entities/regla_categorizacion.dart';
import '../../domain/repositories/reglas_categorizacion_repository.dart';
import '../datasources/reglas_categorizacion_sql_data_source.dart';

class ReglasCategorizacionRepositoryImpl
    implements ReglasCategorizacionRepository {
  ReglasCategorizacionRepositoryImpl(this._dataSource);

  final ReglasCategorizacionSqlDataSource _dataSource;

  @override
  Future<List<ReglaCategorizacion>> obtenerTodas() =>
      _dataSource.obtenerTodas();

  @override
  Future<void> upsert({
    required String palabraClaveComercio,
    required int categoriaId,
  }) {
    return _dataSource.upsert(
      palabraClaveComercio: palabraClaveComercio,
      categoriaId: categoriaId,
    );
  }
}

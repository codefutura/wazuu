import '../../domain/entities/presupuesto.dart';
import '../../domain/repositories/presupuestos_repository.dart';
import '../datasources/presupuestos_sql_data_source.dart';

class PresupuestosRepositoryImpl implements PresupuestosRepository {
  PresupuestosRepositoryImpl(this._dataSource);

  final PresupuestosSqlDataSource _dataSource;

  @override
  Future<List<Presupuesto>> obtenerTodos() => _dataSource.obtenerTodos();

  @override
  Future<void> crear({
    required int? categoriaId,
    required double montoLimite,
    required DateTime fechaInicio,
  }) {
    return _dataSource.crear(
      categoriaId: categoriaId,
      montoLimite: montoLimite,
      fechaInicio: fechaInicio,
    );
  }

  @override
  Future<void> actualizarMonto({required int id, required double montoLimite}) {
    return _dataSource.actualizarMonto(id: id, montoLimite: montoLimite);
  }

  @override
  Future<void> eliminar(int id) => _dataSource.eliminar(id);
}

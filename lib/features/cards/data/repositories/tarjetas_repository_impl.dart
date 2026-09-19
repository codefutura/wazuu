import '../../domain/entities/tarjeta.dart';
import '../../domain/repositories/tarjetas_repository.dart';
import '../datasources/tarjetas_sql_data_source.dart';

class TarjetasRepositoryImpl implements TarjetasRepository {
  TarjetasRepositoryImpl(this._dataSource);

  final TarjetasSqlDataSource _dataSource;

  @override
  Future<List<Tarjeta>> obtenerTodas() => _dataSource.obtenerTodas();

  @override
  Future<void> crear({
    required String apodo,
    required String ultimos4Digitos,
    required TipoTarjeta tipo,
    required int bancoId,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) {
    return _dataSource.crear(
      apodo: apodo,
      ultimos4Digitos: ultimos4Digitos,
      tipo: tipo,
      bancoId: bancoId,
      limiteCredito: limiteCredito,
      fechaCorte: fechaCorte,
      fechaPago: fechaPago,
    );
  }

  @override
  Future<void> actualizar({
    required int id,
    required String apodo,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) {
    return _dataSource.actualizar(
      id: id,
      apodo: apodo,
      limiteCredito: limiteCredito,
      fechaCorte: fechaCorte,
      fechaPago: fechaPago,
    );
  }

  @override
  Future<void> eliminar(int id) => _dataSource.eliminar(id);

  @override
  Future<Tarjeta?> obtenerPorUltimos4Digitos({
    required int bancoId,
    required String ultimos4Digitos,
  }) {
    return _dataSource.obtenerPorUltimos4Digitos(
      bancoId: bancoId,
      ultimos4Digitos: ultimos4Digitos,
    );
  }
}

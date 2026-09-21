import '../../../../core/domain/estado_transaccion.dart';
import '../../../../core/domain/moneda.dart';
import '../../../../core/domain/tipo_transaccion.dart';
import '../../domain/entities/transaccion_huerfana.dart';
import '../../domain/entities/transaccion_registro.dart';
import '../../domain/repositories/transacciones_repository.dart';
import '../datasources/transacciones_sql_data_source.dart';

class TransaccionesRepositoryImpl implements TransaccionesRepository {
  TransaccionesRepositoryImpl(this._dataSource);

  final TransaccionesSqlDataSource _dataSource;

  @override
  Future<List<TransaccionRegistro>> obtener({
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    int? tarjetaId,
  }) {
    return _dataSource.obtener(
      desde: desde,
      hasta: hasta,
      categoriaId: categoriaId,
      tarjetaId: tarjetaId,
    );
  }

  @override
  Future<void> actualizarCategoria({
    required int transaccionId,
    required int categoriaId,
  }) {
    return _dataSource.actualizarCategoria(
      transaccionId: transaccionId,
      categoriaId: categoriaId,
    );
  }

  @override
  Future<bool> insertar({
    required double monto,
    required Moneda moneda,
    required DateTime fecha,
    required String comercio,
    required EstadoTransaccion estado,
    required TipoTransaccion tipoTransaccion,
    required int categoriaId,
    int? tarjetaId,
    required int bancoId,
    required String emailIdOrigen,
    required String hashDedupe,
    String? tarjetaUltimos4Digitos,
  }) {
    return _dataSource.insertar(
      monto: monto,
      moneda: moneda,
      fecha: fecha,
      comercio: comercio,
      estado: estado,
      tipoTransaccion: tipoTransaccion,
      categoriaId: categoriaId,
      tarjetaId: tarjetaId,
      bancoId: bancoId,
      emailIdOrigen: emailIdOrigen,
      hashDedupe: hashDedupe,
      tarjetaUltimos4Digitos: tarjetaUltimos4Digitos,
    );
  }

  @override
  Future<int> reasignarTarjetaHuerfanas({
    required int bancoId,
    required String ultimos4Digitos,
    required int tarjetaId,
  }) {
    return _dataSource.reasignarTarjetaHuerfanas(
      bancoId: bancoId,
      ultimos4Digitos: ultimos4Digitos,
      tarjetaId: tarjetaId,
    );
  }

  @override
  Future<Set<String>> obtenerEmailIdsExistentes(List<String> ids) {
    return _dataSource.obtenerEmailIdsExistentes(ids);
  }

  @override
  Future<List<TransaccionHuerfana>> obtenerHuerfanasPorBanco(int bancoId) {
    return _dataSource.obtenerHuerfanasPorBanco(bancoId);
  }

  @override
  Future<void> vincularTarjeta({
    required int transaccionId,
    required int tarjetaId,
    required String tarjetaUltimos4Digitos,
  }) {
    return _dataSource.vincularTarjeta(
      transaccionId: transaccionId,
      tarjetaId: tarjetaId,
      tarjetaUltimos4Digitos: tarjetaUltimos4Digitos,
    );
  }
}

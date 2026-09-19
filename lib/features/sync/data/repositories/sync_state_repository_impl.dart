import '../../domain/repositories/sync_state_repository.dart';
import '../datasources/sync_state_data_source.dart';

class SyncStateRepositoryImpl implements SyncStateRepository {
  const SyncStateRepositoryImpl(this._dataSource);

  final SyncStateDataSource _dataSource;

  @override
  Future<DateTime?> obtenerUltimaSincronizacion() async {
    return _dataSource.leerUltimaSincronizacion();
  }

  @override
  Future<void> registrarSincronizacion(DateTime momento) {
    return _dataSource.guardarUltimaSincronizacion(momento);
  }
}

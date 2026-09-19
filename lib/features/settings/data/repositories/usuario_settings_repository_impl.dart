import '../../domain/repositories/usuario_settings_repository.dart';
import '../datasources/usuario_settings_sql_data_source.dart';

class UsuarioSettingsRepositoryImpl implements UsuarioSettingsRepository {
  UsuarioSettingsRepositoryImpl(this._dataSource);

  final UsuarioSettingsSqlDataSource _dataSource;

  @override
  Future<double?> obtenerTasaCambioReferencia() =>
      _dataSource.obtenerTasaCambioReferencia();

  @override
  Future<void> establecerTasaCambioReferencia(double tasa) =>
      _dataSource.establecerTasaCambioReferencia(tasa);
}

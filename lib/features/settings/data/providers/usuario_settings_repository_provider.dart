import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../domain/repositories/usuario_settings_repository.dart';
import '../datasources/usuario_settings_sql_data_source.dart';
import '../repositories/usuario_settings_repository_impl.dart';

part 'usuario_settings_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<UsuarioSettingsRepository> usuarioSettingsRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return UsuarioSettingsRepositoryImpl(UsuarioSettingsSqlDataSource(db));
}

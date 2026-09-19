import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../domain/repositories/presupuestos_repository.dart';
import '../datasources/presupuestos_sql_data_source.dart';
import '../repositories/presupuestos_repository_impl.dart';

part 'presupuestos_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<PresupuestosRepository> presupuestosRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return PresupuestosRepositoryImpl(PresupuestosSqlDataSource(db));
}

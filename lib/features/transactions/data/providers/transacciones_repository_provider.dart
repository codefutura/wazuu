import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../domain/repositories/transacciones_repository.dart';
import '../datasources/transacciones_sql_data_source.dart';
import '../repositories/transacciones_repository_impl.dart';

part 'transacciones_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<TransaccionesRepository> transaccionesRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return TransaccionesRepositoryImpl(TransaccionesSqlDataSource(db));
}

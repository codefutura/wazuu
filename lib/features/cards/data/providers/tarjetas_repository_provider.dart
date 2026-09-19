import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../domain/repositories/tarjetas_repository.dart';
import '../datasources/tarjetas_sql_data_source.dart';
import '../repositories/tarjetas_repository_impl.dart';

part 'tarjetas_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<TarjetasRepository> tarjetasRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return TarjetasRepositoryImpl(TarjetasSqlDataSource(db));
}

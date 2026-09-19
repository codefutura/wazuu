import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../domain/entities/banco_conectado.dart';
import '../../domain/repositories/banks_repository.dart';
import '../datasources/banks_sql_data_source.dart';
import '../repositories/banks_repository_impl.dart';

part 'banks_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<BanksRepository> banksRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return BanksRepositoryImpl(BanksSqlDataSource(db));
}

/// Bancos conectados reales (con `id` de base de datos) — usado por el
/// selector de banco al crear una tarjeta.
@riverpod
Future<List<BancoConectado>> bancosConectados(Ref ref) async {
  final repo = await ref.watch(banksRepositoryProvider.future);
  return repo.obtenerConectados();
}

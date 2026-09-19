import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../domain/categorization_engine.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/repositories/categorias_repository.dart';
import '../../domain/repositories/reglas_categorizacion_repository.dart';
import '../datasources/categorias_sql_data_source.dart';
import '../datasources/reglas_categorizacion_sql_data_source.dart';
import '../repositories/categorias_repository_impl.dart';
import '../repositories/reglas_categorizacion_repository_impl.dart';

part 'categorization_providers.g.dart';

@Riverpod(keepAlive: true)
Future<CategoriasRepository> categoriasRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return CategoriasRepositoryImpl(CategoriasSqlDataSource(db));
}

@Riverpod(keepAlive: true)
Future<ReglasCategorizacionRepository> reglasCategorizacionRepository(
  Ref ref,
) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return ReglasCategorizacionRepositoryImpl(
    ReglasCategorizacionSqlDataSource(db),
  );
}

/// Lista completa de categorías — usada por filtros y formularios en
/// otras features (transacciones, presupuestos) que solo necesitan
/// mostrarlas, no categorizar nada.
@riverpod
Future<List<Categoria>> todasLasCategorias(Ref ref) async {
  final repo = await ref.watch(categoriasRepositoryProvider.future);
  return repo.obtenerTodas();
}

@Riverpod(keepAlive: true)
Future<CategorizationEngine> categorizationEngine(Ref ref) async {
  final categorias = await ref.watch(categoriasRepositoryProvider.future);
  final reglas = await ref.watch(
    reglasCategorizacionRepositoryProvider.future,
  );
  return CategorizationEngine(categorias, reglas);
}

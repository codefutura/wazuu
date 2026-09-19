import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../../../core/storage/secure_storage_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_sql_data_source.dart';
import '../datasources/session_secure_data_source.dart';
import '../repositories/auth_repository_impl.dart';
import '../services/password_hasher.dart';

part 'auth_repository_provider.g.dart';

@Riverpod(keepAlive: true)
Future<AuthRepository> authRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(
    AuthSqlDataSource(db),
    const PasswordHasher(),
    SessionSecureDataSource(storage),
  );
}

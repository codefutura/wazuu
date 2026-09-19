import '../../domain/entities/local_account.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_sql_data_source.dart';
import '../datasources/session_secure_data_source.dart';
import '../services/password_hasher.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._hasher, this._sessionDataSource);

  final AuthSqlDataSource _dataSource;
  final PasswordHasher _hasher;
  final SessionSecureDataSource _sessionDataSource;

  @override
  Future<bool> hasAccount() async => (await _dataSource.readAccount()) != null;

  @override
  Future<String?> obtenerEmailGuardado() async =>
      (await _dataSource.readAccount())?.email;

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    final salt = _hasher.generateSalt();
    final hash = _hasher.hash(password: password, salt: salt);
    await _dataSource.saveAccount(
      LocalAccount(
        email: email.trim().toLowerCase(),
        passwordHash: hash,
        passwordSalt: salt,
      ),
    );
  }

  @override
  Future<bool> login({required String email, required String password}) async {
    final account = await _dataSource.readAccount();
    if (account == null) return false;
    if (account.email != email.trim().toLowerCase()) return false;
    final hash = _hasher.hash(password: password, salt: account.passwordSalt);
    return hash == account.passwordHash;
  }

  @override
  Future<void> deleteAccount() async {
    await _dataSource.deleteAccount();
    await _sessionDataSource.cerrar();
  }

  @override
  Future<bool> haySesionActiva() => _sessionDataSource.activa();

  @override
  Future<void> iniciarSesionPersistente() => _sessionDataSource.activar();

  @override
  Future<void> cerrarSesionPersistente() => _sessionDataSource.cerrar();
}

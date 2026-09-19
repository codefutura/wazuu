/// Contrato de autenticación local. La implementación decide dónde vive
/// la cuenta (hoy `flutter_secure_storage`, en la Fase 3 la tabla
/// `usuarios` cifrada con sqlcipher) sin que domain/presentation lo sepan.
abstract interface class AuthRepository {
  Future<bool> hasAccount();

  /// El correo de la cuenta local guardada, si existe — para
  /// precargarlo en la pantalla de login y que el usuario solo tenga
  /// que volver a escribir la contraseña, no el correo también.
  Future<String?> obtenerEmailGuardado();

  Future<void> register({required String email, required String password});

  /// Devuelve `true` si el email y password coinciden con la cuenta local.
  Future<bool> login({required String email, required String password});

  Future<void> deleteAccount();

  /// Sesión persistente entre arranques — distinta de `login`, que
  /// solo valida credenciales. Una vez iniciada, la app abre directo
  /// en el Resumen sin volver a pedir la contraseña, hasta que el
  /// usuario cierre sesión explícitamente.
  Future<bool> haySesionActiva();

  Future<void> iniciarSesionPersistente();

  Future<void> cerrarSesionPersistente();
}

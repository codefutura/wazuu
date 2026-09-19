/// Cuenta local del usuario (email + password hasheado).
///
/// El hash y la sal viven aquí; la contraseña en texto plano nunca se
/// modela como entidad.
class LocalAccount {
  const LocalAccount({
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
  });

  final String email;
  final String passwordHash;
  final String passwordSalt;
}

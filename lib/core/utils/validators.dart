abstract final class Validators {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Ingresa tu correo';
    if (!_emailRegex.hasMatch(trimmed)) return 'Correo inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  static String? Function(String?) confirmPassword(
    String Function() getPassword,
  ) {
    return (value) {
      if (value != getPassword()) return 'Las contraseñas no coinciden';
      return null;
    };
  }
}

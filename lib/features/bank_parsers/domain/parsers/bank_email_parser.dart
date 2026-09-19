import '../entities/raw_email.dart';
import '../entities/transaccion.dart';

/// Patrón Adapter — una implementación por banco (sección 7 de
/// CLAUDE.md).
///
/// Debe devolver `null` si el correo no coincide con una plantilla
/// reconocida — nunca debe adivinar. Un cambio de plantilla del banco
/// hace que esto vuelva `null` (la transacción simplemente no se
/// importa) en vez de romper algo o insertar datos incorrectos.
abstract interface class BankEmailParser {
  Transaccion? parse(RawEmail email);
}

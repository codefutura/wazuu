import '../../../bank_parsers/domain/entities/raw_email.dart';

/// Trae correos desde la Gmail API, ya decodificados a `RawEmail`
/// (sección 7 de CLAUDE.md: los parsers nunca ven el envoltorio MIME
/// crudo). Interfaz aparte de `GmailAuthRepository` — esa maneja la
/// cuenta/token, esta el contenido de los correos.
abstract interface class GmailMessagesFetcher {
  /// IDs de mensajes de `remitentes`, opcionalmente solo después de
  /// `despues` (sincronización incremental).
  Future<List<String>> listarIds({
    required String accessToken,
    required List<String> remitentes,
    DateTime? despues,
  });

  Future<RawEmail> obtenerCorreo({
    required String accessToken,
    required String messageId,
  });
}

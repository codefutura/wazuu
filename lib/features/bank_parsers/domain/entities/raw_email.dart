/// Correo ya decodificado (headers + cuerpo en texto plano y/o HTML)
/// listo para que un `BankEmailParser` lo interprete.
///
/// La decodificación MIME (quoted-printable, charset, `=?...?=` del
/// asunto) ocurre antes de llegar aquí — al traer el mensaje desde la
/// Gmail API (Fase 4) — para que los parsers trabajen siempre sobre
/// texto plano, nunca sobre el envoltorio MIME crudo.
class RawEmail {
  const RawEmail({
    required this.id,
    required this.from,
    required this.subject,
    this.plainTextBody,
    this.htmlBody,
  });

  /// ID del mensaje en Gmail — se propaga a `Transaccion.emailIdOrigen`
  /// para la deduplicación (sección 6 de CLAUDE.md).
  final String id;
  final String from;
  final String subject;
  final String? plainTextBody;
  final String? htmlBody;
}

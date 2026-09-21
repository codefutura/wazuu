/// Gmail respondió con "Quota exceeded" (límite de solicitudes por
/// minuto agotado) — el sync se detiene ahí en vez de reventar con el
/// error crudo, y no marca la sincronización como completa para que
/// los correos restantes se recojan en el siguiente intento.
class GmailQuotaExceededException implements Exception {
  const GmailQuotaExceededException();

  @override
  String toString() =>
      'Gmail limitó las solicitudes por unos minutos (límite de cuota).';
}

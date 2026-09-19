/// Conexión activa con Gmail: cuenta autorizada y el access token vigente
/// para llamar a la API con scope `gmail.readonly`.
class GmailConnection {
  const GmailConnection({
    required this.email,
    required this.accessToken,
    required this.accessTokenExpiry,
  });

  final String email;
  final String accessToken;
  final DateTime accessTokenExpiry;

  bool get isExpired => DateTime.now().isAfter(accessTokenExpiry);
}

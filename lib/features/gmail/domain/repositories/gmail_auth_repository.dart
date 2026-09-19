import '../entities/gmail_connection.dart';

abstract interface class GmailAuthRepository {
  /// Conexión guardada, si existe. No valida si el access token sigue
  /// vigente — usar `GmailConnection.isExpired` para eso.
  Future<GmailConnection?> currentConnection();

  /// Dispara el flujo OAuth completo pidiendo únicamente el scope
  /// `gmail.readonly` (sección 2 de CLAUDE.md — nunca `gmail.modify` ni
  /// `gmail.send`).
  Future<GmailConnection> connect();

  /// Revoca el acceso otorgado y borra la conexión guardada.
  Future<void> disconnect();

  /// Conexión con un access token vigente, renovándolo en silencio si
  /// venció — usado por el motor de sincronización. `null` si no hay
  /// cuenta conectada o la sesión nativa ya no es válida (hace falta
  /// reconectar manualmente).
  Future<GmailConnection?> obtenerConexionValida();
}

/// Resultado de una corrida del motor de sincronización.
class SyncResult {
  const SyncResult({
    required this.transaccionesNuevas,
    this.transaccionesVinculadas = 0,
    this.error,
  });

  final int transaccionesNuevas;

  /// Transacciones que ya existían (sincronizadas antes de que su
  /// tarjeta se conectara) y se acaban de vincular retroactivamente en
  /// esta corrida — ver `GmailSyncService._repararVinculosDeTarjeta`.
  final int transaccionesVinculadas;

  /// Mensaje para mostrarle al usuario si algo impidió sincronizar
  /// (sin Gmail conectado, sin bancos conectados, etc.) — `null` si
  /// corrió sin problemas, aunque no haya encontrado nada nuevo.
  final String? error;
}

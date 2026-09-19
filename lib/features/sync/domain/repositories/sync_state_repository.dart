abstract interface class SyncStateRepository {
  /// `null` si nunca se ha sincronizado — el motor busca correos sin
  /// límite de fecha la primera vez.
  Future<DateTime?> obtenerUltimaSincronizacion();

  Future<void> registrarSincronizacion(DateTime momento);
}

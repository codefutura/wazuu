abstract interface class UsuarioSettingsRepository {
  /// `null` si el usuario todavía no ha configurado una tasa de cambio.
  /// El resumen mensual debe tratar esto como "no se puede consolidar
  /// DOP/USD todavía", nunca asumir un valor.
  Future<double?> obtenerTasaCambioReferencia();

  /// Ajustes → tasa de cambio manual (sección 9.6 de CLAUDE.md).
  Future<void> establecerTasaCambioReferencia(double tasa);
}

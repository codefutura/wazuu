import 'package:shared_preferences/shared_preferences.dart';

/// Guarda cuándo corrió la última sincronización con Gmail.
///
/// Igual que el progreso de onboarding y las alertas de presupuesto:
/// no es parte del modelo de datos de la sección 6 ni información
/// sensible, por eso vive en `SharedPreferences` y no en SQLite.
class SyncStateDataSource {
  SyncStateDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'gmail_last_sync_epoch_seconds';

  DateTime? leerUltimaSincronizacion() {
    final epoch = _prefs.getInt(_key);
    if (epoch == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
  }

  Future<void> guardarUltimaSincronizacion(DateTime momento) {
    return _prefs.setInt(_key, momento.millisecondsSinceEpoch ~/ 1000);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

/// Registra qué alertas de presupuesto ya se notificaron (por
/// presupuesto + umbral + mes) para no repetir la misma notificación
/// cada vez que se recalculan los presupuestos.
///
/// Interino, igual que el progreso del onboarding: no es información
/// sensible ni parte del modelo de datos de la sección 6, por eso vive
/// en `SharedPreferences` y no en SQLite.
class BudgetAlertStateDataSource {
  BudgetAlertStateDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'budget_alerts_notified';

  Set<String> _leerNotificadas() =>
      (_prefs.getStringList(_key) ?? const <String>[]).toSet();

  bool yaNotificada(String clave) => _leerNotificadas().contains(clave);

  Future<void> marcarNotificada(String clave) {
    final actuales = _leerNotificadas()..add(clave);
    return _prefs.setStringList(_key, actuales.toList());
  }
}

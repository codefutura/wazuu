import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// Instancia única de `SharedPreferences`.
///
/// Interino: guarda hoy el progreso del onboarding (datos no sensibles).
/// La Fase 3 mueve ese progreso a SQLite y este provider queda disponible
/// para preferencias de UI no sensibles (ej. tema forzado en Ajustes).
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) =>
    SharedPreferences.getInstance();

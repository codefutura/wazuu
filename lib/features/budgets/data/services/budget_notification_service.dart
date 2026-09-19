import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Permite reemplazar el envío real de notificaciones por un doble de
/// prueba en tests, sin depender del plugin nativo.
abstract interface class BudgetNotificationSender {
  Future<void> mostrarAlerta({
    required int id,
    required String titulo,
    required String cuerpo,
  });
}

/// Envoltorio delgado sobre `flutter_local_notifications` (sección 2 de
/// CLAUDE.md).
class BudgetNotificationService implements BudgetNotificationSender {
  BudgetNotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
    _initialized = true;
  }

  @override
  Future<void> mostrarAlerta({
    required int id,
    required String titulo,
    required String cuerpo,
  }) async {
    await _ensureInitialized();
    const androidDetails = AndroidNotificationDetails(
      'presupuestos',
      'Alertas de presupuesto',
      channelDescription:
          'Avisa cuando te acercas o superas un presupuesto (80%/100%)',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      id: id,
      title: titulo,
      body: cuerpo,
      notificationDetails: details,
    );
  }
}

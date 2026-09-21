import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/core/theme/app_theme.dart';
import 'package:wazuu/features/banks/data/providers/banks_repository_provider.dart';
import 'package:wazuu/features/banks/domain/entities/banco_conectado.dart';
import 'package:wazuu/features/banks/domain/entities/bank_option.dart';
import 'package:wazuu/features/banks/domain/repositories/banks_repository.dart';
import 'package:wazuu/features/cards/data/providers/tarjetas_repository_provider.dart';
import 'package:wazuu/features/cards/domain/entities/tarjeta.dart';
import 'package:wazuu/features/cards/domain/repositories/tarjetas_repository.dart';
import 'package:wazuu/features/gmail/data/providers/gmail_auth_repository_provider.dart';
import 'package:wazuu/features/gmail/domain/entities/gmail_connection.dart';
import 'package:wazuu/features/gmail/domain/repositories/gmail_auth_repository.dart';
import 'package:wazuu/features/settings/data/providers/usuario_settings_repository_provider.dart';
import 'package:wazuu/features/settings/domain/repositories/usuario_settings_repository.dart';
import 'package:wazuu/features/settings/presentation/screens/settings_screen.dart';
import 'package:wazuu/features/transactions/data/providers/transacciones_repository_provider.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_huerfana.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_registro.dart';
import 'package:wazuu/features/transactions/domain/repositories/transacciones_repository.dart';

class _FakeUsuarioSettingsRepository implements UsuarioSettingsRepository {
  double? tasa;

  @override
  Future<double?> obtenerTasaCambioReferencia() async => tasa;

  @override
  Future<void> establecerTasaCambioReferencia(double nuevaTasa) async {
    tasa = nuevaTasa;
  }
}

class _FakeBanksRepository implements BanksRepository {
  Set<String> conectados = {};

  @override
  List<BankOption> supportedBanks() => supportedBanksCatalog;

  @override
  Future<void> saveConnectedBanks(Set<String> bankIds) async {
    conectados = bankIds;
  }

  @override
  Future<Set<String>> connectedBankIds() async => conectados;

  @override
  Future<List<BancoConectado>> obtenerConectados() async {
    return supportedBanksCatalog
        .where((b) => conectados.contains(b.id))
        .toList()
        .asMap()
        .entries
        .map(
          (e) => BancoConectado(
            id: e.key + 1,
            nombreBanco: e.value.name,
            remitenteEmail: e.value.senderEmail,
          ),
        )
        .toList();
  }
}

class _FakeTarjetasRepository implements TarjetasRepository {
  final List<Tarjeta> _items = [];
  int _nextId = 1;

  @override
  Future<List<Tarjeta>> obtenerTodas() async => List.unmodifiable(_items);

  @override
  Future<void> crear({
    required String apodo,
    required String ultimos4Digitos,
    required TipoTarjeta tipo,
    required int bancoId,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) async {
    _items.add(
      Tarjeta(
        id: _nextId++,
        apodo: apodo,
        ultimos4Digitos: ultimos4Digitos,
        tipo: tipo,
        bancoId: bancoId,
        nombreBanco: 'Banco',
        limiteCredito: limiteCredito,
      ),
    );
  }

  @override
  Future<void> actualizar({
    required int id,
    required String apodo,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) async {
    final index = _items.indexWhere((t) => t.id == id);
    final existente = _items[index];
    _items[index] = Tarjeta(
      id: existente.id,
      apodo: apodo,
      ultimos4Digitos: existente.ultimos4Digitos,
      tipo: existente.tipo,
      bancoId: existente.bancoId,
      nombreBanco: existente.nombreBanco,
      limiteCredito: limiteCredito,
    );
  }

  @override
  Future<void> eliminar(int id) async {
    _items.removeWhere((t) => t.id == id);
  }

  @override
  Future<Tarjeta?> obtenerPorUltimos4Digitos({
    required int bancoId,
    required String ultimos4Digitos,
  }) async {
    for (final t in _items) {
      if (t.bancoId == bancoId && t.ultimos4Digitos == ultimos4Digitos) {
        return t;
      }
    }
    return null;
  }
}

class _FakeGmailAuthRepository implements GmailAuthRepository {
  GmailConnection? connection;

  @override
  Future<GmailConnection?> currentConnection() async => connection;

  @override
  Future<GmailConnection> connect() async {
    connection = GmailConnection(
      email: 'usuario@gmail.com',
      accessToken: 'fake-token',
      accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
    );
    return connection!;
  }

  @override
  Future<void> disconnect() async {
    connection = null;
  }

  @override
  Future<GmailConnection?> obtenerConexionValida() async => connection;
}

class _FakeTransaccionesRepository implements TransaccionesRepository {
  @override
  Future<int> reasignarTarjetaHuerfanas({
    required int bancoId,
    required String ultimos4Digitos,
    required int tarjetaId,
  }) async => 0;

  @override
  Future<List<TransaccionHuerfana>> obtenerHuerfanasPorBanco(
    int bancoId,
  ) async => [];

  @override
  Future<void> vincularTarjeta({
    required int transaccionId,
    required int tarjetaId,
    required String tarjetaUltimos4Digitos,
  }) async {}

  @override
  Future<bool> insertar({
    required double monto,
    required Moneda moneda,
    required DateTime fecha,
    required String comercio,
    required EstadoTransaccion estado,
    required TipoTransaccion tipoTransaccion,
    required int categoriaId,
    int? tarjetaId,
    required int bancoId,
    required String emailIdOrigen,
    required String hashDedupe,
    String? tarjetaUltimos4Digitos,
  }) async => true;

  @override
  Future<List<TransaccionRegistro>> obtener({
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    int? tarjetaId,
  }) async => [];

  @override
  Future<void> actualizarCategoria({
    required int transaccionId,
    required int categoriaId,
  }) async {}

  @override
  Future<Set<String>> obtenerEmailIdsExistentes(List<String> ids) async => {};
}

void main() {
  testWidgets('Ajustes: tema, tasa de cambio, bancos y tarjetas', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final settingsRepo = _FakeUsuarioSettingsRepository();
    final banksRepo = _FakeBanksRepository()..conectados = {'bhd'};
    final tarjetasRepo = _FakeTarjetasRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usuarioSettingsRepositoryProvider.overrideWith(
            (ref) async => settingsRepo,
          ),
          banksRepositoryProvider.overrideWith((ref) async => banksRepo),
          tarjetasRepositoryProvider.overrideWith(
            (ref) async => tarjetasRepo,
          ),
          transaccionesRepositoryProvider.overrideWith(
            (ref) async => _FakeTransaccionesRepository(),
          ),
          gmailAuthRepositoryProvider.overrideWithValue(
            _FakeGmailAuthRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // --- Tasa de cambio ---
    await tester.enterText(find.byType(TextField), '60.50');
    await tester.tap(find.text('Guardar').first);
    await tester.pumpAndSettle();
    expect(find.text('Tasa de cambio actualizada'), findsOneWidget);
    expect(settingsRepo.tasa, 60.5);
    // Deja que el snackbar agote su temporizador antes del siguiente, igual
    // que en el flujo de Gmail (pumpAndSettle no espera Timers estáticos).
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // --- Bancos conectados ---
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Banreservas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar').last);
    await tester.pumpAndSettle();
    expect(find.text('Bancos conectados actualizados'), findsOneWidget);
    expect(banksRepo.conectados, {'bhd', 'banreservas'});

    // --- Tarjetas: crear ---
    await tester.ensureVisible(find.text('Aún no tienes tarjetas.'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes tarjetas.'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithIcon(IconButton, Icons.add));
    await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Apodo'),
      'Visa Gold',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Últimos 4 dígitos'),
      '2319',
    );
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BHD').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear tarjeta'));
    await tester.pumpAndSettle();

    // El ListView virtualiza sus hijos fuera de pantalla: cerrar el modal
    // de creación corre el scroll y la sección de Tarjetas se desmonta del
    // árbol, así que hay que reencontrarla antes de las aserciones.
    await tester.dragUntilVisible(
      find.text('Visa Gold'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.text('Visa Gold'), findsOneWidget);
    expect(find.text('•••• 2319 · Banco'), findsOneWidget);

    // --- Tarjetas: eliminar ---
    await tester.ensureVisible(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar').last);
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Aún no tienes tarjetas.'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.text('Visa Gold'), findsNothing);
    expect(find.text('Aún no tienes tarjetas.'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}

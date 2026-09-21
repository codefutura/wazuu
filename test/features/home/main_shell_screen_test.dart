import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wazuu/core/domain/estado_transaccion.dart';
import 'package:wazuu/core/domain/moneda.dart';
import 'package:wazuu/core/domain/tipo_transaccion.dart';
import 'package:wazuu/features/auth/data/providers/auth_repository_provider.dart';
import 'package:wazuu/features/auth/domain/repositories/auth_repository.dart';
import 'package:wazuu/features/cards/data/providers/tarjetas_repository_provider.dart';
import 'package:wazuu/features/cards/domain/entities/tarjeta.dart';
import 'package:wazuu/features/cards/domain/repositories/tarjetas_repository.dart';
import 'package:wazuu/features/categorization/data/providers/categorization_providers.dart';
import 'package:wazuu/features/categorization/domain/entities/categoria.dart';
import 'package:wazuu/features/categorization/domain/entities/regla_categorizacion.dart';
import 'package:wazuu/features/categorization/domain/repositories/categorias_repository.dart';
import 'package:wazuu/features/categorization/domain/repositories/reglas_categorizacion_repository.dart';
import 'package:wazuu/features/onboarding/data/providers/onboarding_repository_provider.dart';
import 'package:wazuu/features/onboarding/domain/entities/onboarding_progress.dart';
import 'package:wazuu/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:wazuu/features/settings/data/providers/usuario_settings_repository_provider.dart';
import 'package:wazuu/features/settings/domain/repositories/usuario_settings_repository.dart';
import 'package:wazuu/features/transactions/data/providers/transacciones_repository_provider.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_huerfana.dart';
import 'package:wazuu/features/transactions/domain/entities/transaccion_registro.dart';
import 'package:wazuu/features/transactions/domain/repositories/transacciones_repository.dart';
import 'package:wazuu/main.dart';

class _FakeAuthRepository implements AuthRepository {
  bool sesionActivaValue = false;

  @override
  Future<bool> hasAccount() async => true;

  @override
  Future<String?> obtenerEmailGuardado() async => 'a@b.com';

  @override
  Future<void> register({required String email, required String password}) async {}

  @override
  Future<bool> login({required String email, required String password}) async => true;

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<bool> haySesionActiva() async => sesionActivaValue;

  @override
  Future<void> iniciarSesionPersistente() async => sesionActivaValue = true;

  @override
  Future<void> cerrarSesionPersistente() async => sesionActivaValue = false;
}

class _FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<OnboardingProgress> load() async => const OnboardingProgress(
    privacySeen: true,
    gmailConnected: true,
    budgetSet: true,
    completed: true,
  );

  @override
  Future<void> save(OnboardingProgress progress) async {}

  @override
  Future<void> clear() async {}
}

class _EmptyTarjetasRepository implements TarjetasRepository {
  @override
  Future<List<Tarjeta>> obtenerTodas() async => [];

  @override
  Future<void> crear({
    required String apodo,
    required String ultimos4Digitos,
    required TipoTarjeta tipo,
    required int bancoId,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) async {}

  @override
  Future<void> actualizar({
    required int id,
    required String apodo,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) async {}

  @override
  Future<void> eliminar(int id) async {}

  @override
  Future<Tarjeta?> obtenerPorUltimos4Digitos({
    required int bancoId,
    required String ultimos4Digitos,
  }) async => null;
}

class _EmptyTransaccionesRepository implements TransaccionesRepository {
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
  Future<Set<String>> obtenerEmailIdsExistentes(List<String> ids) async => {};
}

class _EmptyCategoriasRepository implements CategoriasRepository {
  @override
  Future<List<Categoria>> obtenerTodas() async => [];

  @override
  Future<Categoria> obtenerCategoriaOtro(TipoTransaccion tipo) async {
    throw UnimplementedError('No hay transacciones en este test');
  }
}

class _EmptyReglasRepository implements ReglasCategorizacionRepository {
  @override
  Future<List<ReglaCategorizacion>> obtenerTodas() async => [];

  @override
  Future<void> upsert({
    required String palabraClaveComercio,
    required int categoriaId,
  }) async {}
}

class _NullTasaSettingsRepository implements UsuarioSettingsRepository {
  @override
  Future<double?> obtenerTasaCambioReferencia() async => null;

  @override
  Future<void> establecerTasaCambioReferencia(double tasa) async {}
}

const _tarjetaCredito = Tarjeta(
  id: 1,
  apodo: 'Visa Gold',
  ultimos4Digitos: '2319',
  tipo: TipoTarjeta.credito,
  bancoId: 1,
  nombreBanco: 'Banco Popular Dominicano',
  limiteCredito: 1000,
);

const _categoriaCompras = Categoria(
  id: 1,
  nombre: 'Compras',
  tipo: TipoTransaccion.gasto,
  color: '#0F766E',
  icono: 'shopping_bag',
);
const _categoriaNomina = Categoria(
  id: 8,
  nombre: 'Nómina',
  tipo: TipoTransaccion.ingreso,
  color: '#22C55E',
  icono: 'payments',
);

class _ConTarjetasRepository implements TarjetasRepository {
  @override
  Future<List<Tarjeta>> obtenerTodas() async => const [_tarjetaCredito];

  @override
  Future<void> crear({
    required String apodo,
    required String ultimos4Digitos,
    required TipoTarjeta tipo,
    required int bancoId,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) async {}

  @override
  Future<void> actualizar({
    required int id,
    required String apodo,
    double? limiteCredito,
    DateTime? fechaCorte,
    DateTime? fechaPago,
  }) async {}

  @override
  Future<void> eliminar(int id) async {}

  @override
  Future<Tarjeta?> obtenerPorUltimos4Digitos({
    required int bancoId,
    required String ultimos4Digitos,
  }) async => null;
}

class _ConTransaccionesRepository implements TransaccionesRepository {
  @override
  Future<List<TransaccionRegistro>> obtener({
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    int? tarjetaId,
  }) async {
    final ahora = DateTime.now();
    final todas = [
      TransaccionRegistro(
        id: 1,
        monto: 250,
        moneda: Moneda.dop,
        fecha: DateTime(ahora.year, ahora.month, 10),
        comercio: 'CFN FERRECENTRO',
        estado: EstadoTransaccion.aprobada,
        tipoTransaccion: TipoTransaccion.gasto,
        categoria: _categoriaCompras,
        bancoId: 1,
        nombreBanco: 'Banco Popular Dominicano',
        tarjetaId: _tarjetaCredito.id,
        tarjetaApodo: _tarjetaCredito.apodo,
        tarjetaUltimos4Digitos: _tarjetaCredito.ultimos4Digitos,
      ),
      TransaccionRegistro(
        id: 2,
        monto: 30000,
        moneda: Moneda.dop,
        fecha: DateTime(ahora.year, ahora.month, 1),
        comercio: 'Nómina',
        estado: EstadoTransaccion.aprobada,
        tipoTransaccion: TipoTransaccion.ingreso,
        categoria: _categoriaNomina,
        bancoId: 1,
        nombreBanco: 'Banco Popular Dominicano',
      ),
    ];
    if (tarjetaId == null) return todas;
    return todas.where((t) => t.tarjetaId == tarjetaId).toList();
  }

  @override
  Future<void> actualizarCategoria({
    required int transaccionId,
    required int categoriaId,
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
  Future<Set<String>> obtenerEmailIdsExistentes(List<String> ids) async => {};
}

class _ConCategoriasRepository implements CategoriasRepository {
  @override
  Future<List<Categoria>> obtenerTodas() async => const [
    _categoriaCompras,
    _categoriaNomina,
  ];

  @override
  Future<Categoria> obtenerCategoriaOtro(TipoTransaccion tipo) async =>
      tipo == TipoTransaccion.gasto ? _categoriaCompras : _categoriaNomina;
}

class _ConTasaSettingsRepository implements UsuarioSettingsRepository {
  @override
  Future<double?> obtenerTasaCambioReferencia() async => 60;

  @override
  Future<void> establecerTasaCambioReferencia(double tasa) async {}
}

void main() {
  testWidgets(
    'Las 3 pantallas principales muestran su estado vacío correctamente',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWith(
              (ref) async => _FakeAuthRepository(),
            ),
            onboardingRepositoryProvider.overrideWith(
              (ref) async => _FakeOnboardingRepository(),
            ),
            tarjetasRepositoryProvider.overrideWith(
              (ref) async => _EmptyTarjetasRepository(),
            ),
            transaccionesRepositoryProvider.overrideWith(
              (ref) async => _EmptyTransaccionesRepository(),
            ),
            categoriasRepositoryProvider.overrideWith(
              (ref) async => _EmptyCategoriasRepository(),
            ),
            reglasCategorizacionRepositoryProvider.overrideWith(
              (ref) async => _EmptyReglasRepository(),
            ),
            usuarioSettingsRepositoryProvider.overrideWith(
              (ref) async => _NullTasaSettingsRepository(),
            ),
          ],
          child: const WazuuApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Cuenta ya existe y onboarding está completo -> pantalla de login.
      expect(find.text('Ingresa con tu contraseña local'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();

      // Resumen mensual (pestaña inicial).
      expect(find.text('Aún no tienes transacciones'), findsOneWidget);

      await tester.tap(find.text('Transacciones'));
      await tester.pumpAndSettle();
      expect(find.text('Aún no tienes transacciones'), findsOneWidget);

      await tester.tap(find.text('Tarjetas'));
      await tester.pumpAndSettle();
      expect(find.text('Aún no tienes tarjetas registradas'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Con datos reales, las 3 pantallas renderizan sin crashear',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWith(
              (ref) async => _FakeAuthRepository(),
            ),
            onboardingRepositoryProvider.overrideWith(
              (ref) async => _FakeOnboardingRepository(),
            ),
            tarjetasRepositoryProvider.overrideWith(
              (ref) async => _ConTarjetasRepository(),
            ),
            transaccionesRepositoryProvider.overrideWith(
              (ref) async => _ConTransaccionesRepository(),
            ),
            categoriasRepositoryProvider.overrideWith(
              (ref) async => _ConCategoriasRepository(),
            ),
            reglasCategorizacionRepositoryProvider.overrideWith(
              (ref) async => _EmptyReglasRepository(),
            ),
            usuarioSettingsRepositoryProvider.overrideWith(
              (ref) async => _ConTasaSettingsRepository(),
            ),
          ],
          child: const WazuuApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();

      // Resumen mensual: gasto del mes (el ingreso ya no se muestra —
      // los bancos no notifican depósitos, solo retiros/consumos).
      expect(find.textContaining('RD\$250.00'), findsOneWidget);
      expect(find.text('Tendencia de 6 meses'), findsOneWidget);

      // Gasto por categoría, después de tendencia — queda debajo del
      // viewport visible, hay que bajar el scroll para verlo.
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Gasto por categoría'), findsOneWidget);
      expect(find.text('Compras'), findsOneWidget);

      await tester.tap(find.text('Transacciones'));
      await tester.pumpAndSettle();
      expect(find.text('CFN FERRECENTRO'), findsOneWidget);
      expect(find.text('Nómina'), findsWidgets);

      await tester.tap(find.text('Tarjetas'));
      await tester.pumpAndSettle();
      expect(find.text('Visa Gold'), findsOneWidget);
      expect(find.textContaining('25%'), findsOneWidget); // 250/1000

      // Tocar la tarjeta salta a Transacciones ya filtrada por ella
      // (sección 9.3 de CLAUDE.md).
      await tester.tap(find.text('Visa Gold'));
      await tester.pumpAndSettle();
      expect(find.text('CFN FERRECENTRO'), findsOneWidget);
      expect(find.text('Nómina'), findsNothing);

      // El menú lateral reemplaza el ícono de ajustes del AppBar.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Configuración'), findsOneWidget);
      expect(find.text('Ayuda'), findsOneWidget);
      expect(find.text('Acerca de'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
}

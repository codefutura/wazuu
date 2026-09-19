import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/core/app_flow/app_flow_controller.dart';
import 'package:wazuu/core/app_flow/app_flow_state.dart';
import 'package:wazuu/features/auth/data/providers/auth_repository_provider.dart';
import 'package:wazuu/features/auth/domain/repositories/auth_repository.dart';
import 'package:wazuu/features/budgets/data/providers/presupuestos_repository_provider.dart';
import 'package:wazuu/features/budgets/domain/entities/presupuesto.dart';
import 'package:wazuu/features/budgets/domain/repositories/presupuestos_repository.dart';
import 'package:wazuu/features/onboarding/data/providers/onboarding_repository_provider.dart';
import 'package:wazuu/features/onboarding/domain/entities/onboarding_progress.dart';
import 'package:wazuu/features/onboarding/domain/repositories/onboarding_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({bool sesionActivaInicial = false})
    : _sesionActiva = sesionActivaInicial;

  bool _sesionActiva;
  String? passwordRegistrada;

  @override
  Future<bool> hasAccount() async => true;

  @override
  Future<String?> obtenerEmailGuardado() async => 'a@b.com';

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    passwordRegistrada = password;
  }

  @override
  Future<bool> login({required String email, required String password}) async =>
      password == passwordRegistrada;

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<bool> haySesionActiva() async => _sesionActiva;

  @override
  Future<void> iniciarSesionPersistente() async => _sesionActiva = true;

  @override
  Future<void> cerrarSesionPersistente() async => _sesionActiva = false;
}

class _FakeOnboardingRepository implements OnboardingRepository {
  OnboardingProgress _progress = const OnboardingProgress(
    privacySeen: true,
    gmailConnected: true,
    budgetSet: true,
  );

  @override
  Future<OnboardingProgress> load() async => _progress;

  @override
  Future<void> save(OnboardingProgress progress) async {
    _progress = progress;
  }

  @override
  Future<void> clear() async {
    _progress = const OnboardingProgress();
  }
}

class _FakePresupuestosRepository implements PresupuestosRepository {
  final List<({int? categoriaId, double montoLimite, DateTime fechaInicio})>
  creados = [];

  @override
  Future<void> crear({
    required int? categoriaId,
    required double montoLimite,
    required DateTime fechaInicio,
  }) async {
    creados.add((
      categoriaId: categoriaId,
      montoLimite: montoLimite,
      fechaInicio: fechaInicio,
    ));
  }

  @override
  Future<List<Presupuesto>> obtenerTodos() async => [];

  @override
  Future<void> actualizarMonto({
    required int id,
    required double montoLimite,
  }) => throw UnimplementedError();

  @override
  Future<void> eliminar(int id) => throw UnimplementedError();
}

void main() {
  test(
    'setInitialBudget crea el presupuesto total real, no solo el '
    'progreso del onboarding',
    () async {
      final presupuestosRepo = _FakePresupuestosRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            (ref) async => _FakeAuthRepository(),
          ),
          onboardingRepositoryProvider.overrideWith(
            (ref) async => _FakeOnboardingRepository(),
          ),
          presupuestosRepositoryProvider.overrideWith(
            (ref) async => presupuestosRepo,
          ),
        ],
      );
      addTearDown(container.dispose);

      // Deja que `build()` resuelva antes de invocar el método.
      await container.read(appFlowControllerProvider.future);

      await container
          .read(appFlowControllerProvider.notifier)
          .setInitialBudget(15000);

      expect(presupuestosRepo.creados, hasLength(1));
      expect(presupuestosRepo.creados.single.categoriaId, isNull);
      expect(presupuestosRepo.creados.single.montoLimite, 15000);
    },
  );

  group('sesión persistente', () {
    ProviderContainer construirContainer(_FakeAuthRepository authRepo) {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) async => authRepo),
          onboardingRepositoryProvider.overrideWith(
            (ref) async => _FakeOnboardingRepository(),
          ),
          presupuestosRepositoryProvider.overrideWith(
            (ref) async => _FakePresupuestosRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test(
      'sin sesión activa, un arranque en frío pide login (no auto-entra)',
      () async {
        final container = construirContainer(_FakeAuthRepository());

        final estado = await container.read(appFlowControllerProvider.future);

        expect(estado, isA<AppFlowLogin>());
      },
    );

    test(
      'con sesión ya persistida, un arranque en frío entra directo sin pedir contraseña',
      () async {
        final container = construirContainer(
          _FakeAuthRepository(sesionActivaInicial: true),
        );

        final estado = await container.read(appFlowControllerProvider.future);

        expect(estado, isA<AppFlowHome>());
      },
    );

    test('login exitoso deja la sesión activa para el próximo arranque', () async {
      final authRepo = _FakeAuthRepository();
      final container = construirContainer(authRepo);
      await container.read(appFlowControllerProvider.future);
      await authRepo.register(email: 'a@b.com', password: 'clave123');

      final exito = await container
          .read(appFlowControllerProvider.notifier)
          .login(email: 'a@b.com', password: 'clave123');

      expect(exito, isTrue);
      expect(await authRepo.haySesionActiva(), isTrue);
      expect(container.read(appFlowControllerProvider).value, isA<AppFlowHome>());
    });

    test('logout cierra la sesión persistida, no solo la de memoria', () async {
      final authRepo = _FakeAuthRepository(sesionActivaInicial: true);
      final container = construirContainer(authRepo);
      await container.read(appFlowControllerProvider.future);
      expect(
        container.read(appFlowControllerProvider).value,
        isA<AppFlowHome>(),
      );

      // logout() dispara `_logout()` sin esperarlo (unawaited) — deja
      // que ese macrotask corra antes de volver a leer `.future`, que
      // para entonces ya apunta al ciclo de carga que `_logout()`
      // disparó.
      container.read(appFlowControllerProvider.notifier).logout();
      await Future<void>.delayed(Duration.zero);
      final estado = await container.read(appFlowControllerProvider.future);

      expect(await authRepo.haySesionActiva(), isFalse);
      expect(estado, isA<AppFlowLogin>());
    });
  });
}

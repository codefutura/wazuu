import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wazuu/features/auth/data/providers/auth_repository_provider.dart';
import 'package:wazuu/features/auth/domain/repositories/auth_repository.dart';
import 'package:wazuu/features/onboarding/data/providers/onboarding_repository_provider.dart';
import 'package:wazuu/features/onboarding/domain/entities/onboarding_progress.dart';
import 'package:wazuu/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:wazuu/main.dart';

class _FakeAuthRepository implements AuthRepository {
  bool hasAccountValue = false;
  bool sesionActivaValue = false;

  @override
  Future<bool> hasAccount() async => hasAccountValue;

  @override
  Future<String?> obtenerEmailGuardado() async =>
      hasAccountValue ? 'a@b.com' : null;

  @override
  Future<void> register({required String email, required String password}) async {
    hasAccountValue = true;
  }

  @override
  Future<bool> login({required String email, required String password}) async => true;

  @override
  Future<void> deleteAccount() async => hasAccountValue = false;

  @override
  Future<bool> haySesionActiva() async => sesionActivaValue;

  @override
  Future<void> iniciarSesionPersistente() async => sesionActivaValue = true;

  @override
  Future<void> cerrarSesionPersistente() async => sesionActivaValue = false;
}

class _FakeOnboardingRepository implements OnboardingRepository {
  OnboardingProgress _progress = const OnboardingProgress();

  @override
  Future<OnboardingProgress> load() async => _progress;

  @override
  Future<void> save(OnboardingProgress progress) async => _progress = progress;

  @override
  Future<void> clear() async => _progress = const OnboardingProgress();
}

void main() {
  testWidgets('Cuenta nueva arranca en el carrusel de privacidad', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith(
            (ref) async => _FakeAuthRepository(),
          ),
          onboardingRepositoryProvider.overrideWith(
            (ref) async => _FakeOnboardingRepository(),
          ),
        ],
        child: const WazuuApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Solo miramos, no tocamos'), findsOneWidget);
  });

  testWidgets(
    'Onboarding completo llega a la pantalla de Gmail sin crashear',
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
          ],
          child: const WazuuApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Carrusel de privacidad: 3 "Siguiente" + 1 "Comenzar".
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Siguiente'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Comenzar'));
      await tester.pumpAndSettle();

      expect(find.text('Crea tu cuenta local'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      // Deja que el snackbar de "Cuenta creada" agote su temporizador
      // (pumpAndSettle no espera Timers estáticos) para que no quede en
      // cola bloqueando el siguiente snackbar.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(find.text('Conecta tu Gmail'), findsOneWidget);

      // Sin plugin nativo disponible en el test, esto debe fallar
      // limpiamente (snackbar), no crashear la app.
      await tester.tap(find.text('Conectar con Google'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(find.textContaining('No se pudo conectar'), findsOneWidget);
      expect(find.text('Conectar con Google'), findsOneWidget);
    },
  );
}

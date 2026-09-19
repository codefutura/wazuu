import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wazuu/features/auth/data/providers/auth_repository_provider.dart';
import 'package:wazuu/features/auth/domain/repositories/auth_repository.dart';
import 'package:wazuu/features/auth/presentation/screens/login_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.emailGuardado});

  final String? emailGuardado;

  @override
  Future<bool> hasAccount() async => emailGuardado != null;

  @override
  Future<String?> obtenerEmailGuardado() async => emailGuardado;

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {}

  @override
  Future<bool> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<bool> haySesionActiva() async => false;

  @override
  Future<void> iniciarSesionPersistente() async {}

  @override
  Future<void> cerrarSesionPersistente() async {}
}

void main() {
  testWidgets(
    'precarga el correo de la cuenta local guardada',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWith(
              (ref) async =>
                  _FakeAuthRepository(emailGuardado: 'yo@gmail.com'),
            ),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('yo@gmail.com'), findsOneWidget);
    },
  );

  testWidgets(
    'sin cuenta guardada, el campo de correo empieza vacío',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWith(
              (ref) async => _FakeAuthRepository(),
            ),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final campoCorreo = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Correo'),
      );
      expect(campoCorreo.controller?.text, isEmpty);
    },
  );
}

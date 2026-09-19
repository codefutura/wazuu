import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/providers/auth_repository_provider.dart';
import '../../features/banks/data/providers/banks_repository_provider.dart';
import '../../features/budgets/data/providers/presupuestos_repository_provider.dart';
import '../../features/onboarding/data/providers/onboarding_repository_provider.dart';
import 'app_flow_state.dart';

part 'app_flow_controller.g.dart';

/// Orquesta a qué pantalla debe ir el usuario al abrir la app,
/// combinando la cuenta local (Auth) con el progreso del onboarding.
///
/// La sesión es persistente entre arranques (Keychain/Keystore, ver
/// `SessionSecureDataSource`): una vez que el usuario entra con su
/// contraseña, la app vuelve a abrir directo en el Resumen hasta que
/// cierre sesión explícitamente — no vuelve a pedir la contraseña en
/// cada arranque en frío.
@Riverpod(keepAlive: true)
class AppFlowController extends _$AppFlowController {
  @override
  Future<AppFlowState> build() => _resolve();

  Future<AppFlowState> _resolve() async {
    final authRepository = await ref.read(authRepositoryProvider.future);
    final onboardingRepository = await ref.read(
      onboardingRepositoryProvider.future,
    );
    final hasAccount = await authRepository.hasAccount();
    var progress = await onboardingRepository.load();

    if (!hasAccount) {
      if (!progress.privacySeen) return const AppFlowPrivacyCarousel();
      return const AppFlowCreateAccount();
    }

    if (!progress.gmailConnected) return const AppFlowConnectGmail();
    if (!progress.budgetSet) return const AppFlowInitialBudget();

    if (!progress.completed) {
      progress = progress.copyWith(completed: true);
      await onboardingRepository.save(progress);
    }

    final sesionActiva = await authRepository.haySesionActiva();
    return sesionActiva ? const AppFlowHome() : const AppFlowLogin();
  }

  Future<void> _refresh() async {
    state = const AsyncLoading<AppFlowState>();
    state = AsyncData(await _resolve());
  }

  Future<void> completePrivacyCarousel() async {
    final onboardingRepository = await ref.read(
      onboardingRepositoryProvider.future,
    );
    final progress = await onboardingRepository.load();
    await onboardingRepository.save(progress.copyWith(privacySeen: true));
    await _refresh();
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final authRepository = await ref.read(authRepositoryProvider.future);
    await authRepository.register(email: email, password: password);
    await authRepository.iniciarSesionPersistente();
    await _refresh();
  }

  /// Devuelve `true` si las credenciales son válidas.
  Future<bool> login({required String email, required String password}) async {
    final authRepository = await ref.read(authRepositoryProvider.future);
    final success = await authRepository.login(email: email, password: password);
    if (success) {
      await authRepository.iniciarSesionPersistente();
      await _refresh();
    }
    return success;
  }

  void logout() {
    unawaited(_logout());
  }

  Future<void> _logout() async {
    final authRepository = await ref.read(authRepositoryProvider.future);
    await authRepository.cerrarSesionPersistente();
    await _refresh();
  }

  Future<void> completeGmailStep(Set<String> selectedBankIds) async {
    final banksRepository = await ref.read(banksRepositoryProvider.future);
    await banksRepository.saveConnectedBanks(selectedBankIds);

    final onboardingRepository = await ref.read(
      onboardingRepositoryProvider.future,
    );
    final progress = await onboardingRepository.load();
    await onboardingRepository.save(progress.copyWith(gmailConnected: true));
    await _refresh();
  }

  Future<void> setInitialBudget(double amount) async {
    // El onboarding solo recoge un monto total (sin categoría) — se
    // traduce directo al presupuesto total real (categoriaId null,
    // sección 6 de CLAUDE.md), no solo al progreso del onboarding
    // (bug real: antes se guardaba `initialBudgetAmount` ahí y nunca
    // llegaba a la tabla `presupuestos`, así que nunca aparecía en la
    // pantalla de Presupuestos).
    final presupuestosRepository = await ref.read(
      presupuestosRepositoryProvider.future,
    );
    await presupuestosRepository.crear(
      categoriaId: null,
      montoLimite: amount,
      fechaInicio: DateTime.now(),
    );

    final onboardingRepository = await ref.read(
      onboardingRepositoryProvider.future,
    );
    final progress = await onboardingRepository.load();
    await onboardingRepository.save(
      progress.copyWith(
        budgetSet: true,
        initialBudgetAmount: amount,
        completed: true,
      ),
    );
    await _refresh();
  }

  Future<void> skipInitialBudget() async {
    final onboardingRepository = await ref.read(
      onboardingRepositoryProvider.future,
    );
    final progress = await onboardingRepository.load();
    await onboardingRepository.save(
      progress.copyWith(budgetSet: true, completed: true),
    );
    await _refresh();
  }
}

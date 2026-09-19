import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/onboarding_progress.dart';

/// Persistencia del progreso del onboarding en `SharedPreferences`.
///
/// Interino: la Fase 3 mueve el resto del modelo de datos a SQLite
/// (sección 6 de CLAUDE.md). Este progreso no es información sensible,
/// por eso no necesita `flutter_secure_storage`.
class OnboardingLocalDataSource {
  OnboardingLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _keyPrivacySeen = 'onboarding_privacy_seen';
  static const _keyGmailConnected = 'onboarding_gmail_connected';
  static const _keyBudgetSet = 'onboarding_budget_set';
  static const _keyInitialBudgetAmount = 'onboarding_initial_budget_amount';
  static const _keyCompleted = 'onboarding_completed';

  OnboardingProgress read() {
    return OnboardingProgress(
      privacySeen: _prefs.getBool(_keyPrivacySeen) ?? false,
      gmailConnected: _prefs.getBool(_keyGmailConnected) ?? false,
      budgetSet: _prefs.getBool(_keyBudgetSet) ?? false,
      initialBudgetAmount: _prefs.getDouble(_keyInitialBudgetAmount),
      completed: _prefs.getBool(_keyCompleted) ?? false,
    );
  }

  Future<void> write(OnboardingProgress progress) async {
    await _prefs.setBool(_keyPrivacySeen, progress.privacySeen);
    await _prefs.setBool(_keyGmailConnected, progress.gmailConnected);
    await _prefs.setBool(_keyBudgetSet, progress.budgetSet);
    if (progress.initialBudgetAmount != null) {
      await _prefs.setDouble(
        _keyInitialBudgetAmount,
        progress.initialBudgetAmount!,
      );
    }
    await _prefs.setBool(_keyCompleted, progress.completed);
  }

  Future<void> clear() async {
    await _prefs.remove(_keyPrivacySeen);
    await _prefs.remove(_keyGmailConnected);
    await _prefs.remove(_keyBudgetSet);
    await _prefs.remove(_keyInitialBudgetAmount);
    await _prefs.remove(_keyCompleted);
  }
}

/// Progreso del wizard de configuración inicial (ver sección 5 de
/// CLAUDE.md). Se guarda para poder retomar el onboarding si el usuario
/// cierra la app a mitad de camino.
class OnboardingProgress {
  const OnboardingProgress({
    this.privacySeen = false,
    this.gmailConnected = false,
    this.budgetSet = false,
    this.initialBudgetAmount,
    this.completed = false,
  });

  final bool privacySeen;
  final bool gmailConnected;
  final bool budgetSet;
  final double? initialBudgetAmount;
  final bool completed;

  OnboardingProgress copyWith({
    bool? privacySeen,
    bool? gmailConnected,
    bool? budgetSet,
    double? initialBudgetAmount,
    bool? completed,
  }) {
    return OnboardingProgress(
      privacySeen: privacySeen ?? this.privacySeen,
      gmailConnected: gmailConnected ?? this.gmailConnected,
      budgetSet: budgetSet ?? this.budgetSet,
      initialBudgetAmount: initialBudgetAmount ?? this.initialBudgetAmount,
      completed: completed ?? this.completed,
    );
  }
}

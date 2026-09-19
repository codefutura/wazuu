/// Pantalla que corresponde mostrar en la raíz de la app según el estado
/// de la cuenta local y el progreso del onboarding.
sealed class AppFlowState {
  const AppFlowState();
}

class AppFlowPrivacyCarousel extends AppFlowState {
  const AppFlowPrivacyCarousel();
}

class AppFlowCreateAccount extends AppFlowState {
  const AppFlowCreateAccount();
}

class AppFlowConnectGmail extends AppFlowState {
  const AppFlowConnectGmail();
}

class AppFlowInitialBudget extends AppFlowState {
  const AppFlowInitialBudget();
}

class AppFlowLogin extends AppFlowState {
  const AppFlowLogin();
}

class AppFlowHome extends AppFlowState {
  const AppFlowHome();
}

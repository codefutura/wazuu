import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/create_account_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/main_shell_screen.dart';
import '../../features/onboarding/presentation/screens/connect_gmail_screen.dart';
import '../../features/onboarding/presentation/screens/initial_budget_screen.dart';
import '../../features/onboarding/presentation/screens/privacy_carousel_screen.dart';
import 'app_flow_controller.dart';
import 'app_flow_state.dart';

/// Punto de entrada de la UI: decide qué pantalla mostrar según el
/// estado combinado de cuenta local + progreso de onboarding, sin que
/// ninguna pantalla necesite conocer a las demás.
class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(appFlowControllerProvider);

    return flow.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text('No se pudo iniciar Wazuu: $error')),
      ),
      data: (state) => AnimatedSwitcher(
        // Sección 4 de CLAUDE.md: transiciones de 200-300ms.
        duration: const Duration(milliseconds: 250),
        child: switch (state) {
          AppFlowPrivacyCarousel() => const PrivacyCarouselScreen(),
          AppFlowCreateAccount() => const CreateAccountScreen(),
          AppFlowConnectGmail() => const ConnectGmailScreen(),
          AppFlowInitialBudget() => const InitialBudgetScreen(),
          AppFlowLogin() => const LoginScreen(),
          AppFlowHome() => const MainShellScreen(),
        },
      ),
    );
  }
}

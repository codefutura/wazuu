import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/create_account_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/main_shell_screen.dart';
import '../../features/onboarding/presentation/screens/connect_gmail_screen.dart';
import '../../features/onboarding/presentation/screens/initial_budget_screen.dart';
import '../../features/onboarding/presentation/screens/privacy_carousel_screen.dart';
import '../widgets/skeleton_box.dart';
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
      loading: () => const Scaffold(body: _AppGateSkeleton()),
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

/// Se muestra mientras se resuelve a qué pantalla ir (cuenta local +
/// progreso de onboarding) — aún no se sabe cuál será el destino final,
/// así que imita una estructura genérica de pantalla en vez de un
/// spinner centrado (sección 4 de CLAUDE.md).
class _AppGateSkeleton extends StatelessWidget {
  const _AppGateSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 140, height: 20),
            const SizedBox(height: 24),
            const SkeletonBox(height: 90, borderRadius: 16),
            const SizedBox(height: 16),
            const SkeletonBox(height: 90, borderRadius: 16),
            const SizedBox(height: 32),
            const SkeletonBox(width: 100, height: 14),
            const SizedBox(height: 12),
            const SkeletonBox(height: 56, borderRadius: 12),
            const SizedBox(height: 12),
            const SkeletonBox(height: 56, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

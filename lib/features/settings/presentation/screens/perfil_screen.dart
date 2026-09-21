import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../auth/data/providers/auth_repository_provider.dart';

/// Perfil — datos de la cuenta local (sección 2 de CLAUDE.md, cuenta
/// única por dispositivo). No hay más datos de perfil que el correo:
/// no se recolecta nombre, foto ni nada adicional.
class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<String?>(
        future: ref
            .read(authRepositoryProvider.future)
            .then((repo) => repo.obtenerEmailGuardado()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return ListView(
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const SkeletonBox(
                          width: 56,
                          height: 56,
                          borderRadius: 28,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              SkeletonBox(width: 90, height: 12),
                              SizedBox(height: 8),
                              SkeletonBox(width: 160, height: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const SkeletonBox(height: 14),
                const SizedBox(height: 6),
                const SkeletonBox(width: 220, height: 14),
              ],
            );
          }
          final email = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.teal,
                        child: Text(
                          (email?.isNotEmpty ?? false)
                              ? email![0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cuenta local',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email ?? 'Sin correo guardado',
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu contraseña se guarda cifrada solo en este dispositivo. '
                'Nadie más, ni siquiera nosotros, puede verla ni '
                'recuperarla.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_flow/app_flow_controller.dart';
import '../../../../core/constants/urls.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/providers/auth_repository_provider.dart';
import '../../../settings/presentation/screens/ayuda_screen.dart';
import '../../../settings/presentation/screens/perfil_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

/// Menú lateral con acceso a Perfil, Configuración, Ayuda y Acerca de
/// — reemplaza el ícono de ajustes en el AppBar, más cómodo de tocar.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.teal,
            // Padding manual (no SafeArea) para que el teal pinte hasta
            // arriba del todo, debajo del status bar, en vez de dejar un
            // hueco del color de fondo por defecto del Drawer.
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/icon-app.jpeg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Wazuu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                FutureBuilder<String?>(
                  future: ref
                      .read(authRepositoryProvider.future)
                      .then((repo) => repo.obtenerEmailGuardado()),
                  builder: (context, snapshot) => Text(
                    snapshot.data ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mintLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Perfil'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PerfilScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Configuración'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Ayuda'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AyudaScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Acerca de'),
                    onTap: () {
                      Navigator.of(context).pop();
                      showAboutDialog(
                        context: context,
                        applicationName: 'Wazuu',
                        applicationVersion: '1.0.0',
                        applicationIcon: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/icon-app.jpeg',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        applicationLegalese:
                            'Finanzas personales para República Dominicana. '
                            'Solo miramos, no tocamos.',
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Política de Privacidad'),
                    onTap: () {
                      Navigator.of(context).pop();
                      launchUrl(
                        Uri.parse(AppUrls.privacyPolicy),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.ios_share_outlined),
                    title: const Text('Compartir Wazuu'),
                    onTap: () {
                      Navigator.of(context).pop();
                      SharePlus.instance.share(
                        ShareParams(
                          text:
                              'Estoy usando Wazuu para llevar el control de '
                              'mis gastos leyendo mis propias notificaciones '
                              'bancarias, sin exponer mis datos a nadie más. '
                              'Solo miramos, no tocamos.',
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Cerrar sesión'),
                    onTap: () {
                      Navigator.of(context).pop();
                      ref.read(appFlowControllerProvider.notifier).logout();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

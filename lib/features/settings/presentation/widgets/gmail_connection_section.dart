import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../gmail/data/providers/gmail_auth_repository_provider.dart';
import '../../../gmail/presentation/providers/gmail_connection_provider.dart';

/// Estado de la cuenta de Gmail conectada, con opción de conectar o
/// desconectar (sección 9.6 y "Tus derechos y control" de la política
/// de privacidad — antes prometido en el texto pero nunca implementado
/// en la interfaz).
class GmailConnectionSection extends ConsumerStatefulWidget {
  const GmailConnectionSection({super.key});

  @override
  ConsumerState<GmailConnectionSection> createState() =>
      _GmailConnectionSectionState();
}

class _GmailConnectionSectionState
    extends ConsumerState<GmailConnectionSection> {
  bool _loading = false;

  Future<void> _connect() async {
    setState(() => _loading = true);
    try {
      await ref.read(gmailAuthRepositoryProvider).connect();
      ref.invalidate(gmailConnectionProvider);
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mensajeErrorGoogle(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _disconnect() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Desconectar Gmail?'),
        content: const Text(
          'Wazuu dejará de poder leer nuevos correos bancarios hasta que '
          'vuelvas a conectar tu cuenta. Tus transacciones ya guardadas '
          'no se eliminan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _loading = true);
    try {
      await ref.read(gmailAuthRepositoryProvider).disconnect();
      ref.invalidate(gmailConnectionProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gmail desconectado')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mensajeErrorGoogle(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Cancelaste la conexión con Google.';
      case GoogleSignInExceptionCode.interrupted:
        return 'La conexión con Google se interrumpió. Intenta de nuevo.';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Hubo un problema de configuración al conectar con Google. '
            'Espera unos segundos e intenta de nuevo.';
      default:
        return 'No se pudo conectar con Google. Intenta de nuevo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionAsync = ref.watch(gmailConnectionProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cuenta de Gmail',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            connectionAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) =>
                  Text('No se pudo revisar la conexión: $error'),
              data: (connection) => connection == null
                  ? OutlinedButton.icon(
                      onPressed: _loading ? null : _connect,
                      icon: _loading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.g_mobiledata),
                      label: Text(
                        _loading ? 'Conectando…' : 'Conectar con Google',
                      ),
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.successText(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Conectado como ${connection.email}'),
                        ),
                        TextButton(
                          onPressed: _loading ? null : _disconnect,
                          child: _loading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Desconectar'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

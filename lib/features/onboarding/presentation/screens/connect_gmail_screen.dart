import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/app_flow/app_flow_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/step_scaffold.dart';
import '../../../banks/domain/entities/bank_option.dart';
import '../../../gmail/data/providers/gmail_auth_repository_provider.dart';

/// Paso 2 del wizard: conectar Gmail (OAuth real, scope `gmail.readonly`
/// únicamente) y elegir qué bancos monitorear.
class ConnectGmailScreen extends ConsumerStatefulWidget {
  const ConnectGmailScreen({super.key});

  @override
  ConsumerState<ConnectGmailScreen> createState() =>
      _ConnectGmailScreenState();
}

class _ConnectGmailScreenState extends ConsumerState<ConnectGmailScreen> {
  bool _connecting = false;
  String? _connectedEmail;
  bool _submitting = false;
  final Set<String> _selectedBankIds = {};

  Future<void> _connect() async {
    setState(() => _connecting = true);
    try {
      final connection = await ref
          .read(gmailAuthRepositoryProvider)
          .connect();
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _connectedEmail = connection.email;
      });
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      setState(() => _connecting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mensajeErrorGoogle(e))));
    } catch (e) {
      if (!mounted) return;
      setState(() => _connecting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo conectar: $e')));
    }
  }

  /// Mensaje legible para los códigos de error más comunes de
  /// `google_sign_in` — el texto crudo de la excepción (útil para
  /// depurar) no le dice nada al usuario sobre qué hacer.
  String _mensajeErrorGoogle(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Cancelaste la conexión con Google.';
      case GoogleSignInExceptionCode.interrupted:
        return 'La conexión con Google se interrumpió. Intenta de nuevo.';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Hubo un problema de configuración al conectar con Google. '
            'Espera unos segundos y toca "Conectar con Google" de nuevo.';
      default:
        return 'No se pudo conectar con Google '
            '(${e.code.name}${e.description != null ? ': ${e.description}' : ''}). '
            'Intenta de nuevo.';
    }
  }

  Future<void> _continue() async {
    setState(() => _submitting = true);
    try {
      await ref
          .read(appFlowControllerProvider.notifier)
          .completeGmailStep(_selectedBankIds);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = _connectedEmail != null;
    final canContinue = connected && _selectedBankIds.isNotEmpty;

    return StepScaffold(
      stepNumber: 2,
      totalSteps: 3,
      title: 'Conecta tu Gmail',
      primaryActionLabel: 'Continuar',
      primaryActionLoading: _submitting,
      onPrimaryAction: canContinue ? _continue : null,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Solo leemos los correos de los bancos que elijas. Nunca '
              'enviamos ni eliminamos nada.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (!connected)
              OutlinedButton.icon(
                onPressed: _connecting ? null : _connect,
                icon: _connecting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.g_mobiledata),
                label: Text(
                  _connecting ? 'Conectando…' : 'Conectar con Google',
                ),
              )
            else ...[
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.successText(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Conectado como $_connectedEmail')),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '¿Qué bancos quieres monitorear?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...supportedBanksCatalog.map(
                (bank) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(bank.name),
                  value: _selectedBankIds.contains(bank.id),
                  onChanged: (checked) {
                    setState(() {
                      if (checked ?? false) {
                        _selectedBankIds.add(bank.id);
                      } else {
                        _selectedBankIds.remove(bank.id);
                      }
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

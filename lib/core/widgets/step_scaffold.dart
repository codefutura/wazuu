import 'package:flutter/material.dart';

/// Estructura común de los pasos del wizard de configuración inicial:
/// indicador de progreso, título, contenido y acciones — misma
/// disposición en los 3 pasos (ver principio de consistencia, sección 4
/// de CLAUDE.md).
class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.stepNumber,
    required this.totalSteps,
    required this.title,
    required this.child,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.primaryActionLoading = false,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final int stepNumber;
  final int totalSteps;
  final String title;
  final Widget child;
  final String primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final bool primaryActionLoading;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: stepNumber / totalSteps),
              ),
              const SizedBox(height: 8),
              Text(
                'Paso $stepNumber de $totalSteps',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              Expanded(child: child),
              if (secondaryActionLabel != null)
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryActionLabel!),
                ),
              FilledButton(
                onPressed: primaryActionLoading ? null : onPrimaryAction,
                child: primaryActionLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(primaryActionLabel),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

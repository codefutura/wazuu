import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_flow/app_flow_controller.dart';
import '../../../../core/widgets/step_scaffold.dart';

/// Paso 3 del wizard: presupuesto inicial. El usuario puede definir un
/// monto total o saltar este paso (ver sección 5 de CLAUDE.md).
///
/// El monto solo se guarda como referencia de onboarding por ahora; la
/// Fase 3 lo traslada a la tabla `presupuestos`.
class InitialBudgetScreen extends ConsumerStatefulWidget {
  const InitialBudgetScreen({super.key});

  @override
  ConsumerState<InitialBudgetScreen> createState() =>
      _InitialBudgetScreenState();
}

class _InitialBudgetScreenState extends ConsumerState<InitialBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    setState(() => _submitting = true);
    try {
      await ref.read(appFlowControllerProvider.notifier).setInitialBudget(amount);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _skip() async {
    setState(() => _submitting = true);
    try {
      await ref.read(appFlowControllerProvider.notifier).skipInitialBudget();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      stepNumber: 3,
      totalSteps: 3,
      title: 'Define tu presupuesto inicial',
      primaryActionLabel: 'Guardar y continuar',
      primaryActionLoading: _submitting,
      onPrimaryAction: _save,
      secondaryActionLabel: 'Saltar por ahora',
      onSecondaryAction: _submitting ? null : _skip,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Puedes ajustarlo después. Si prefieres, sáltalo por ahora.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Presupuesto mensual total (RD\$)',
                  prefixText: 'RD\$ ',
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Ingresa un monto';
                  final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

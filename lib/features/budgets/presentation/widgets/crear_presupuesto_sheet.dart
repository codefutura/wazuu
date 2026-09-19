import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/tipo_transaccion.dart';
import '../../../categorization/data/providers/categorization_providers.dart';
import '../../data/providers/presupuestos_repository_provider.dart';
import '../providers/presupuestos_provider.dart';

/// Formulario para crear un presupuesto — total o por categoría
/// (sección 5 y 9.5 de CLAUDE.md).
class CrearPresupuestoSheet extends ConsumerStatefulWidget {
  const CrearPresupuestoSheet({super.key});

  @override
  ConsumerState<CrearPresupuestoSheet> createState() =>
      _CrearPresupuestoSheetState();
}

class _CrearPresupuestoSheetState extends ConsumerState<CrearPresupuestoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  int? _categoriaId;
  bool _guardando = false;

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final monto = double.parse(_montoController.text.replaceAll(',', '.'));
    setState(() => _guardando = true);
    try {
      final repo = await ref.read(presupuestosRepositoryProvider.future);
      await repo.crear(
        categoriaId: _categoriaId,
        montoLimite: monto,
        fechaInicio: DateTime.now(),
      );
      ref.invalidate(presupuestosConProgresoProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(todasLasCategoriasProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nuevo presupuesto',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            categoriasAsync.when(
              data: (categorias) {
                final categoriasGasto = categorias
                    .where((c) => c.tipo == TipoTransaccion.gasto)
                    .toList();
                return DropdownButtonFormField<int?>(
                  initialValue: _categoriaId,
                  decoration: const InputDecoration(
                    labelText: 'Categoría (opcional)',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Presupuesto total'),
                    ),
                    for (final c in categoriasGasto)
                      DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                  ],
                  onChanged: (value) => setState(() => _categoriaId = value),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) =>
                  Text('No se pudieron cargar las categorías: $error'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _montoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monto límite mensual (RD\$)',
                prefixText: 'RD\$ ',
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return 'Ingresa un monto';
                final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) return 'Ingresa un monto válido';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear presupuesto'),
            ),
          ],
        ),
      ),
    );
  }
}

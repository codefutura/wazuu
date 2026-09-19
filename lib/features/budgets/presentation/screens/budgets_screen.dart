import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/moneda.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/progreso_presupuesto.dart';
import '../providers/presupuestos_provider.dart';
import '../widgets/crear_presupuesto_sheet.dart';
import '../widgets/presupuestos_skeleton.dart';

/// Presupuestos por categoría, con alertas en 80%/100% (sección 9.5 de
/// CLAUDE.md).
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progresosAsync = ref.watch(presupuestosConProgresoProvider);

    return Scaffold(
      body: progresosAsync.when(
        loading: () => const PresupuestosSkeleton(),
        error: (error, stackTrace) => Center(
          child: Text('No se pudieron cargar tus presupuestos: $error'),
        ),
        data: (progresos) {
          if (progresos.isEmpty) {
            return const EmptyState(
              icon: Icons.savings_outlined,
              title: 'Aún no tienes presupuestos',
              message:
                  'Crea uno para llevar control de cuánto gastas por '
                  'categoría cada mes.',
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(presupuestosConProgresoProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: progresos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _PresupuestoCard(progreso: progresos[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const CrearPresupuestoSheet(),
        ),
        tooltip: 'Nuevo presupuesto',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PresupuestoCard extends StatelessWidget {
  const _PresupuestoCard({required this.progreso});

  final ProgresoPresupuesto progreso;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final porcentaje = progreso.porcentaje.clamp(0, 1).toDouble();
    final color = progreso.alcanzoLimite
        ? AppColors.coral
        : progreso.alcanzoAdvertencia
        ? AppColors.warning
        : AppColors.success;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    progreso.categoria?.nombre ?? 'Presupuesto total',
                    style: textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${MoneyFormatter.format(progreso.gastadoDop, Moneda.dop)} / '
                  '${MoneyFormatter.format(progreso.presupuesto.montoLimite, Moneda.dop)}',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: porcentaje,
                minHeight: 8,
                color: color,
              ),
            ),
            if (progreso.usdSinConsolidar) ...[
              const SizedBox(height: 8),
              Text(
                'Tienes gastos en USD sin consolidar — configura tu tasa '
                'de cambio.',
                style: textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

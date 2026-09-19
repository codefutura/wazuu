import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/moneda.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/total_banco.dart';
import '../../domain/entities/totales_transacciones.dart';
import '../../domain/totales_por_banco_calculator.dart';
import '../../domain/totales_transacciones_calculator.dart';
import '../providers/transacciones_filtro_provider.dart';
import '../widgets/filtros_bar.dart';
import '../widgets/transaccion_tile.dart';
import '../widgets/transacciones_skeleton.dart';

/// Lista de transacciones, filtrable por fecha/categoría/tarjeta
/// (sección 9.4 de CLAUDE.md).
class TransactionsListScreen extends ConsumerWidget {
  const TransactionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(transaccionesFiltroControllerProvider);
    final transaccionesAsync = ref.watch(transaccionesFiltradasProvider);

    return Column(
      children: [
        FiltrosBar(filtro: filtro),
        Expanded(
          child: transaccionesAsync.when(
            loading: () => const TransaccionesSkeleton(),
            error: (error, stackTrace) => Center(
              child: Text('No se pudieron cargar las transacciones: $error'),
            ),
            data: (transacciones) {
              if (transacciones.isEmpty) {
                return EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: filtro.esFiltroExplicito
                      ? 'Nada coincide con estos filtros'
                      : 'Aún no tienes transacciones',
                  message: filtro.esFiltroExplicito
                      ? 'Prueba ajustando o limpiando los filtros.'
                      : 'En cuanto lleguen correos de tus bancos '
                            'conectados, las vas a ver aquí.',
                );
              }
              final totalGeneral = const TotalesTransaccionesCalculator()
                  .calcular(transacciones);
              final totalesPorBanco = const TotalesPorBancoCalculator()
                  .calcular(transacciones);
              const encabezados = 1;

              return RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(transaccionesFiltradasProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: transacciones.length + encabezados,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _TotalesPorBanco(
                        porBanco: totalesPorBanco,
                        totalGeneral: totalGeneral,
                      );
                    }
                    return TransaccionTile(
                      transaccion: transacciones[index - encabezados],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Gasto del período desglosado por banco conectado, con la suma total
/// al pie (sección 9.4 de CLAUDE.md — "el total por banco... y al pie
/// la suma total de esas deudas en las dos monedas"). Solo cuenta
/// transacciones aprobadas, igual que el resumen mensual. No se
/// muestra ingreso: los bancos solo notifican retiros/consumos.
class _TotalesPorBanco extends StatelessWidget {
  const _TotalesPorBanco({required this.porBanco, required this.totalGeneral});

  final List<TotalBanco> porBanco;
  final TotalesTransacciones totalGeneral;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total por banco', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final banco in porBanco) ...[
              _FilaTotal(
                etiqueta: banco.nombreBanco,
                color: AppColors.coralText(context),
                montoDop: banco.totales.gastosDop,
                montoUsd: banco.totales.gastosUsd,
                mostrarUsd: banco.totales.hayMovimientoUsd,
              ),
              const SizedBox(height: 4),
            ],
            const Divider(height: 20),
            _FilaTotal(
              etiqueta: 'Total',
              color: AppColors.coralText(context),
              montoDop: totalGeneral.gastosDop,
              montoUsd: totalGeneral.gastosUsd,
              mostrarUsd: totalGeneral.hayMovimientoUsd,
              negrita: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaTotal extends StatelessWidget {
  const _FilaTotal({
    required this.etiqueta,
    required this.color,
    required this.montoDop,
    required this.montoUsd,
    required this.mostrarUsd,
    this.negrita = false,
  });

  final String etiqueta;
  final Color color;
  final double montoDop;
  final double montoUsd;
  final bool mostrarUsd;
  final bool negrita;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: color,
      fontWeight: negrita ? FontWeight.bold : null,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(etiqueta, style: Theme.of(context).textTheme.bodyMedium),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(MoneyFormatter.format(montoDop, Moneda.dop), style: estilo),
            if (mostrarUsd)
              Text(
                MoneyFormatter.format(montoUsd, Moneda.usd),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: color),
              ),
          ],
        ),
      ],
    );
  }
}

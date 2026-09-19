import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/moneda.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../../../core/utils/hex_color.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/categoria_total.dart';
import '../../domain/entities/resumen_mensual.dart';
import '../providers/resumen_mensual_provider.dart';
import '../widgets/resumen_skeleton.dart';
import '../widgets/tendencia_chart.dart';

const _nombresMes = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Resumen mensual — pantalla de inicio (sección 9.2 de CLAUDE.md).
class ResumenMensualScreen extends ConsumerWidget {
  const ResumenMensualScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(resumenMensualProvider);
    final mesesTendencia = ref.watch(rangoTendenciaControllerProvider);

    return resumenAsync.when(
      loading: () => const ResumenSkeleton(),
      error: (error, stackTrace) =>
          Center(child: Text('No se pudo cargar el resumen: $error')),
      data: (data) {
        if (!data.hayTransacciones) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Aún no tienes transacciones',
            message:
                'En cuanto lleguen correos de tus bancos conectados, '
                'tu resumen mensual va a aparecer aquí.',
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(resumenMensualProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BalanceCard(resumen: data.resumen),
              // Sin gasto en USD, esta tarjeta repetiría el mismo número
              // que el titular — solo aporta cuando hay que desglosar
              // por moneda.
              if (data.resumen.gastosUsd != 0) ...[
                const SizedBox(height: 16),
                _DesgloseMoneda(resumen: data.resumen),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tendencia de $mesesTendencia meses',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 3, label: Text('3m')),
                      ButtonSegment(value: 6, label: Text('6m')),
                      ButtonSegment(value: 12, label: Text('12m')),
                    ],
                    selected: {mesesTendencia},
                    showSelectedIcon: false,
                    onSelectionChanged: (seleccion) => ref
                        .read(rangoTendenciaControllerProvider.notifier)
                        .establecer(seleccion.first),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (data.resumen.tendenciaMensual.isEmpty)
                Text(
                  'Configura tu tasa de cambio en Ajustes para ver la '
                  'tendencia.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                TendenciaChart(puntos: data.resumen.tendenciaMensual),
              if (data.resumen.gastoPorCategoria.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Gasto por categoría',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _GastoPorCategoria(categorias: data.resumen.gastoPorCategoria),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.resumen});

  final ResumenMensual resumen;

  @override
  Widget build(BuildContext context) {
    final gasto = resumen.gastoTotalDop;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: AppColors.teal,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gasto de ${_nombresMes[resumen.mes.month - 1]}',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.mintLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              gasto == null
                  ? 'Configura tu tasa de cambio'
                  : MoneyFormatter.format(gasto, Moneda.dop),
              style: textTheme.displaySmall?.copyWith(color: Colors.white),
            ),
            if (resumen.variacionVsMesAnteriorPorcentaje != null) ...[
              const SizedBox(height: 8),
              _Variacion(porcentaje: resumen.variacionVsMesAnteriorPorcentaje!),
            ],
          ],
        ),
      ),
    );
  }
}

class _Variacion extends StatelessWidget {
  const _Variacion({required this.porcentaje});

  final double porcentaje;

  @override
  Widget build(BuildContext context) {
    // Vive siempre sobre el fondo teal de _BalanceCard. El ícono lleva
    // el color semántico vivo (verde/coral) como acento, pero el texto
    // usa warningSoft (amarillo suave) porque el coral/verde vivos
    // pierden legibilidad sobre teal cuando se usan como color de
    // texto completo en vez de solo acento.
    final subiendo = porcentaje >= 0;
    final colorIcono = subiendo ? AppColors.success : AppColors.coral;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          subiendo ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: colorIcono,
        ),
        const SizedBox(width: 4),
        Text(
          '${porcentaje.abs().toStringAsFixed(1)}% vs. mes anterior',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.warningSoft),
        ),
      ],
    );
  }
}

class _DesgloseMoneda extends StatelessWidget {
  const _DesgloseMoneda({required this.resumen});

  final ResumenMensual resumen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Los bancos solo notifican retiros/consumos, no depósitos —
          // por eso este desglose ya no incluye Ingresos (sección 9.2
          // de CLAUDE.md).
          children: [
            _FilaMonto(
              icono: Icons.trending_down,
              color: AppColors.coralText(context),
              etiqueta: 'Gastos',
              montoDop: resumen.gastosDop,
              montoUsd: resumen.gastosUsd,
            ),
          ],
        ),
      ),
    );
  }
}

/// Gasto del mes desglosado por categoría, de mayor a menor (sección
/// 9.2 de CLAUDE.md — "total por categoría después de tendencia").
class _GastoPorCategoria extends StatelessWidget {
  const _GastoPorCategoria({required this.categorias});

  final List<CategoriaTotal> categorias;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            for (final item in categorias)
              _FilaCategoria(categoriaTotal: item),
          ],
        ),
      ),
    );
  }
}

class _FilaCategoria extends StatelessWidget {
  const _FilaCategoria({required this.categoriaTotal});

  final CategoriaTotal categoriaTotal;

  @override
  Widget build(BuildContext context) {
    final categoria = categoriaTotal.categoria;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colorFromHex(categoria.color),
            child: Icon(
              CategoryIconMapper.iconFor(categoria.icono),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(categoria.nombre, style: textTheme.bodyLarge),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MoneyFormatter.format(categoriaTotal.montoDop, Moneda.dop),
                style: textTheme.bodyLarge,
              ),
              if (categoriaTotal.montoUsd != 0)
                Text(
                  MoneyFormatter.format(categoriaTotal.montoUsd, Moneda.usd),
                  style: textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaMonto extends StatelessWidget {
  const _FilaMonto({
    required this.icono,
    required this.color,
    required this.etiqueta,
    required this.montoDop,
    required this.montoUsd,
  });

  final IconData icono;
  final Color color;
  final String etiqueta;
  final double montoDop;
  final double montoUsd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icono, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(etiqueta, style: textTheme.titleMedium)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              MoneyFormatter.format(montoDop, Moneda.dop),
              style: textTheme.titleMedium,
            ),
            if (montoUsd != 0)
              Text(
                MoneyFormatter.format(montoUsd, Moneda.usd),
                style: textTheme.bodySmall,
              ),
          ],
        ),
      ],
    );
  }
}

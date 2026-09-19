import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/domain/moneda.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/resumen_mensual.dart';

/// Gráfica de tendencia del balance neto mensual, en DOP consolidado
/// (sección 9.2 de CLAUDE.md). Muestra valores en el eje y un tooltip
/// al tocar un punto — sin eso, una curva sin escala no se entiende.
class TendenciaChart extends StatelessWidget {
  const TendenciaChart({super.key, required this.puntos});

  final List<PuntoTendenciaMensual> puntos;

  static const _nombresMes = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  static String _compacto(double valor) {
    final signo = valor < 0 ? '-' : '';
    final abs = valor.abs();
    if (abs >= 1000) return '$signo${(abs / 1000).toStringAsFixed(1)}k';
    return '$signo${abs.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < puntos.length; i++)
        FlSpot(i.toDouble(), puntos[i].balanceNetoDop),
    ];
    final valores = puntos.map((p) => p.balanceNetoDop);
    final maximo = valores.fold(0.0, (a, b) => b > a ? b : a);
    final minimo = valores.fold(0.0, (a, b) => b < a ? b : a);
    // Evita un eje sin rango cuando todos los meses dan el mismo valor
    // (ej. un solo mes con datos).
    final intervaloEjeY = ((maximo - minimo) / 4).abs();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: intervaloEjeY == 0 ? null : intervaloEjeY,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: intervaloEjeY == 0 ? null : intervaloEjeY,
                getTitlesWidget: (value, meta) => Text(
                  _compacto(value),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= puntos.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _nombresMes[puntos[index].mes.month - 1],
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    '${_nombresMes[puntos[spot.x.toInt()].mes.month - 1]}: '
                    '${MoneyFormatter.format(spot.y, Moneda.dop)}',
                    Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.teal,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.mintLight.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

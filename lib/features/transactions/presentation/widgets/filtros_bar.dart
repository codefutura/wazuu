import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/transacciones_filtro_provider.dart';

class FiltrosBar extends ConsumerWidget {
  const FiltrosBar({super.key, required this.filtro});

  final TransaccionesFiltro filtro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasGastoProvider);
    final tarjetasAsync = ref.watch(tarjetasDisponiblesProvider);
    final controller = ref.read(
      transaccionesFiltroControllerProvider.notifier,
    );

    final categoriaNombre = categoriasAsync.maybeWhen(
      data: (categorias) => _buscarNombre(
        categorias,
        filtro.categoriaId,
        idDe: (c) => c.id,
        nombreDe: (c) => c.nombre,
      ),
      orElse: () => null,
    );
    final tarjetaApodo = tarjetasAsync.maybeWhen(
      data: (tarjetas) => _buscarNombre(
        tarjetas,
        filtro.tarjetaId,
        idDe: (t) => t.id,
        nombreDe: (t) => t.apodo,
      ),
      orElse: () => null,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                categoriasAsync.when(
                  data: (categorias) => DropdownButton<int?>(
                    hint: const Text('Categoría'),
                    value: filtro.categoriaId,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas'),
                      ),
                      for (final c in categorias)
                        DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                    ],
                    onChanged: controller.establecerCategoria,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 12),
                tarjetasAsync.when(
                  data: (tarjetas) => DropdownButton<int?>(
                    hint: const Text('Tarjeta'),
                    value: filtro.tarjetaId,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas'),
                      ),
                      for (final t in tarjetas)
                        DropdownMenuItem(value: t.id, child: Text(t.apodo)),
                    ],
                    onChanged: controller.establecerTarjeta,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range_outlined, size: 18),
                  label: Text(
                    filtro.desde == null
                        ? 'Fecha'
                        : '${_formatoFecha(filtro.desde!)} - '
                              '${filtro.hasta == null ? '...' : _formatoFecha(filtro.hasta!)}',
                  ),
                  onPressed: () async {
                    final rango = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange:
                          filtro.desde != null && filtro.hasta != null
                          ? DateTimeRange(
                              start: filtro.desde!,
                              // `hasta` se guarda al final del día
                              // (23:59:59.999) para que el filtro
                              // incluya el día completo — se trunca
                              // de vuelta a medianoche solo para
                              // mostrarlo en el picker, que si no
                              // podría chocar con `lastDate` cuando
                              // el rango termina hoy mismo.
                              end: DateTime(
                                filtro.hasta!.year,
                                filtro.hasta!.month,
                                filtro.hasta!.day,
                              ),
                            )
                          : null,
                      // El botón "Guardar" del diálogo por defecto queda
                      // casi invisible (texto pequeño sin fondo) — se le
                      // da más peso visual solo dentro de este diálogo.
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.teal,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (rango != null) {
                      controller.establecerRangoFechas(rango.start, rango.end);
                    }
                  },
                ),
                if (filtro.tieneFiltrosActivos) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: controller.limpiar,
                    child: const Text('Limpiar'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.filter_alt_outlined,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _descripcionFiltro(
                    categoriaNombre: categoriaNombre,
                    tarjetaApodo: tarjetaApodo,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String? _buscarNombre<T>(
    List<T> items,
    int? id, {
    required int Function(T) idDe,
    required String Function(T) nombreDe,
  }) {
    if (id == null) return null;
    for (final item in items) {
      if (idDe(item) == id) return nombreDe(item);
    }
    return null;
  }

  /// Deja explícito qué rango/categoría/tarjeta está afectando tanto
  /// la lista como el total de abajo — sección 9.4 de CLAUDE.md.
  String _descripcionFiltro({String? categoriaNombre, String? tarjetaApodo}) {
    final partes = <String>[];
    if (filtro.esRangoPorDefecto && filtro.desde != null) {
      partes.add(_nombreMes(filtro.desde!));
    } else if (filtro.desde != null && filtro.hasta != null) {
      partes.add(
        '${_formatoFecha(filtro.desde!)} - ${_formatoFecha(filtro.hasta!)}',
      );
    } else if (filtro.desde != null) {
      partes.add('desde ${_formatoFecha(filtro.desde!)}');
    } else if (filtro.hasta != null) {
      partes.add('hasta ${_formatoFecha(filtro.hasta!)}');
    }
    if (categoriaNombre != null) partes.add(categoriaNombre);
    if (tarjetaApodo != null) partes.add(tarjetaApodo);

    if (partes.isEmpty) return 'Mostrando todo el historial';
    return 'Mostrando: ${partes.join(' · ')}';
  }

  static const _nombresMes = [
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

  static String _nombreMes(DateTime fecha) =>
      '${_nombresMes[fecha.month - 1]} ${fecha.year}';

  static String _formatoFecha(DateTime fecha) => '${fecha.day}/${fecha.month}';
}

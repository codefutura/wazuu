import 'package:flutter/material.dart';

import '../../../../core/domain/estado_transaccion.dart';
import '../../../../core/domain/tipo_transaccion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../../../core/utils/hex_color.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/transaccion_registro.dart';

/// Detalle completo de una transacción (sección 9.4 de CLAUDE.md) — se
/// abre desde el ícono de información en cada fila, sin interferir con
/// tocar la fila para recategorizar.
class TransaccionDetalleDialog extends StatelessWidget {
  const TransaccionDetalleDialog({super.key, required this.transaccion});

  final TransaccionRegistro transaccion;

  static Future<void> mostrar(
    BuildContext context,
    TransaccionRegistro transaccion,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => TransaccionDetalleDialog(transaccion: transaccion),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final esIngreso = transaccion.tipoTransaccion == TipoTransaccion.ingreso;
    final esAprobada = transaccion.estado == EstadoTransaccion.aprobada;
    final colorMonto = esIngreso
        ? AppColors.successText(context)
        : Theme.of(context).colorScheme.onSurface;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorFromHex(transaccion.categoria.color),
                  child: Icon(
                    CategoryIconMapper.iconFor(transaccion.categoria.icono),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    transaccion.comercio,
                    style: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${esIngreso ? '+' : '-'}'
              '${MoneyFormatter.format(transaccion.monto, transaccion.moneda)}',
              style: textTheme.headlineMedium?.copyWith(
                color: colorMonto,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _Fila(
              etiqueta: 'Fecha',
              valor: _formatoFechaCompleta(transaccion.fecha),
            ),
            _Fila(etiqueta: 'Categoría', valor: transaccion.categoria.nombre),
            _Fila(
              etiqueta: 'Tipo',
              valor: esIngreso ? 'Ingreso' : 'Gasto',
            ),
            _Fila(
              etiqueta: 'Estado',
              valor: esAprobada ? 'Aprobada' : 'Declinada',
              colorValor: esAprobada
                  ? AppColors.successText(context)
                  : AppColors.coralText(context),
            ),
            _Fila(etiqueta: 'Banco', valor: transaccion.nombreBanco),
            if (transaccion.tarjetaApodo != null)
              _Fila(
                etiqueta: 'Tarjeta',
                valor:
                    '${transaccion.tarjetaApodo} '
                    '(•••• ${transaccion.tarjetaUltimos4Digitos})',
              )
            else
              const _Fila(
                etiqueta: 'Tarjeta',
                valor: 'Sin vincular todavía',
              ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatoFechaCompleta(DateTime fecha) {
    const meses = [
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
    final hora = fecha.hour == 0 && fecha.minute == 0
        ? ''
        : ' · ${fecha.hour.toString().padLeft(2, '0')}:'
              '${fecha.minute.toString().padLeft(2, '0')}';
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}$hora';
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.etiqueta, required this.valor, this.colorValor});

  final String etiqueta;
  final String valor;
  final Color? colorValor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              etiqueta,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorValor,
                fontWeight: colorValor != null ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/tipo_transaccion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../../../core/utils/hex_color.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../categorization/data/providers/categorization_providers.dart';
import '../../../categorization/domain/entities/categoria.dart';
import '../../data/providers/transacciones_repository_provider.dart';
import '../../domain/entities/transaccion_registro.dart';
import '../providers/transacciones_filtro_provider.dart';
import 'seleccionar_categoria_sheet.dart';
import 'transaccion_detalle_dialog.dart';

/// Tolerancia a errores (sección 4 de CLAUDE.md): tocar una transacción
/// permite recategorizarla — la corrección alimenta el motor de
/// aprendizaje de la Fase 6, no solo cambia esta transacción puntual.
class TransaccionTile extends ConsumerWidget {
  const TransaccionTile({super.key, required this.transaccion});

  final TransaccionRegistro transaccion;

  Future<void> _recategorizar(BuildContext context, WidgetRef ref) async {
    final nuevaCategoria = await showModalBottomSheet<Categoria>(
      context: context,
      builder: (context) =>
          SeleccionarCategoriaSheet(tipo: transaccion.tipoTransaccion),
    );
    if (nuevaCategoria == null || nuevaCategoria.id == transaccion.categoria.id) {
      return;
    }

    final engine = await ref.read(categorizationEngineProvider.future);
    await engine.aprenderDeRecategorizacion(
      comercio: transaccion.comercio,
      categoriaId: nuevaCategoria.id,
    );

    final repo = await ref.read(transaccionesRepositoryProvider.future);
    await repo.actualizarCategoria(
      transaccionId: transaccion.id,
      categoriaId: nuevaCategoria.id,
    );

    ref.invalidate(transaccionesFiltradasProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recategorizado como "${nuevaCategoria.nombre}"')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final esIngreso = transaccion.tipoTransaccion == TipoTransaccion.ingreso;
    final colorMonto = esIngreso
        ? AppColors.successText(context)
        : Theme.of(context).colorScheme.onSurface;
    final fecha = transaccion.fecha;
    final subtitulo = [
      '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}',
      transaccion.categoria.nombre,
      if (transaccion.tarjetaApodo != null) transaccion.tarjetaApodo!,
    ].join(' • ');

    final colorCategoria = colorFromHex(transaccion.categoria.color);

    return Card(
      // Sin esto, el margen por defecto del Card (4px en las 4
      // direcciones) se suma al separator del ListView y a la llegada
      // a los bordes de pantalla — el espaciado entre tarjetas lo
      // controla únicamente el separator de abajo.
      margin: EdgeInsets.zero,
      // Toque sutil: un tinte apenas perceptible del color de la
      // categoría en vez del blanco/superficie plano por defecto.
      color: Color.alphaBlend(
        colorCategoria.withValues(alpha: 0.05),
        Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
      ),
      child: ListTile(
        onTap: () => _recategorizar(context, ref),
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        leading: CircleAvatar(
          backgroundColor: colorCategoria,
          child: Icon(
            CategoryIconMapper.iconFor(transaccion.categoria.icono),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          transaccion.comercio,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${esIngreso ? '+' : '-'}'
              '${MoneyFormatter.format(transaccion.monto, transaccion.moneda)}',
              style: textTheme.titleMedium?.copyWith(
                color: colorMonto,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              tooltip: 'Ver detalles',
              onPressed: () =>
                  TransaccionDetalleDialog.mostrar(context, transaccion),
            ),
          ],
        ),
      ),
    );
  }
}

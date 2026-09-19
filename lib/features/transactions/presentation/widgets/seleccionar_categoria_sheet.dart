import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/tipo_transaccion.dart';
import '../../../../core/utils/category_icon_mapper.dart';
import '../../../../core/utils/hex_color.dart';
import '../../../categorization/data/providers/categorization_providers.dart';

/// Elegir una categoría nueva para una transacción — solo muestra
/// categorías del mismo tipo (gasto/ingreso), ya que no tendría sentido
/// recategorizar un gasto como "Nómina".
class SeleccionarCategoriaSheet extends ConsumerWidget {
  const SeleccionarCategoriaSheet({super.key, required this.tipo});

  final TipoTransaccion tipo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(todasLasCategoriasProvider);

    return SafeArea(
      child: categoriasAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No se pudieron cargar las categorías: $error'),
        ),
        data: (categorias) {
          final filtradas = categorias.where((c) => c.tipo == tipo).toList();
          return ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Elegir categoría',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final categoria in filtradas)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorFromHex(categoria.color),
                    child: Icon(
                      CategoryIconMapper.iconFor(categoria.icono),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(categoria.nombre),
                  onTap: () => Navigator.of(context).pop(categoria),
                ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

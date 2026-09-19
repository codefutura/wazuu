import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cards/data/providers/tarjetas_repository_provider.dart';
import '../../../cards/domain/entities/tarjeta.dart';
import '../../../cards/presentation/providers/lista_tarjetas_provider.dart';
import '../../../cards/presentation/providers/tarjetas_consumo_provider.dart';
import '../../../cards/presentation/widgets/crear_editar_tarjeta_sheet.dart';

class TarjetasSection extends ConsumerWidget {
  const TarjetasSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tarjetasAsync = ref.watch(listaTarjetasProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tus tarjetas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Agregar tarjeta',
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const CrearEditarTarjetaSheet(),
                  ),
                ),
              ],
            ),
            tarjetasAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: LinearProgressIndicator(),
              ),
              error: (error, stackTrace) =>
                  Text('No se pudieron cargar tus tarjetas: $error'),
              data: (tarjetas) {
                if (tarjetas.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Aún no tienes tarjetas.'),
                  );
                }
                return Column(
                  children: tarjetas
                      .map((tarjeta) => _TarjetaTile(tarjeta: tarjeta))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaTile extends ConsumerWidget {
  const _TarjetaTile({required this.tarjeta});

  final Tarjeta tarjeta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        tarjeta.tipo == TipoTarjeta.credito
            ? Icons.credit_card
            : Icons.payments_outlined,
      ),
      title: Text(tarjeta.apodo),
      subtitle: Text('•••• ${tarjeta.ultimos4Digitos} · ${tarjeta.nombreBanco}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) =>
                  CrearEditarTarjetaSheet(tarjetaExistente: tarjeta),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar',
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Eliminar tarjeta?'),
                  content: Text(
                    'Se eliminará "${tarjeta.apodo}". Las transacciones ya '
                    'registradas con esta tarjeta no se borran.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              if (confirmar != true) return;
              final repo = await ref.read(tarjetasRepositoryProvider.future);
              await repo.eliminar(tarjeta.id);
              ref.invalidate(listaTarjetasProvider);
              ref.invalidate(tarjetasConsumoProvider);
            },
          ),
        ],
      ),
    );
  }
}

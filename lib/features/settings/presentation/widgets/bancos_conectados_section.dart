import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../banks/domain/entities/bank_option.dart';
import '../providers/bancos_seleccionados_provider.dart';

class BancosConectadosSection extends ConsumerWidget {
  const BancosConectadosSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seleccionAsync = ref.watch(bancosSeleccionadosControllerProvider);
    final controller = ref.read(
      bancosSeleccionadosControllerProvider.notifier,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bancos conectados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Solo leemos correos de los bancos que marques aquí.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            seleccionAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: LinearProgressIndicator(),
              ),
              error: (error, stackTrace) =>
                  Text('No se pudieron cargar tus bancos: $error'),
              data: (seleccionados) => Column(
                children: [
                  ...supportedBanksCatalog.map(
                    (bank) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(bank.name),
                      value: seleccionados.contains(bank.id),
                      onChanged: (_) => controller.alternar(bank.id),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () async {
                        await controller.guardar();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bancos conectados actualizados'),
                            ),
                          );
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

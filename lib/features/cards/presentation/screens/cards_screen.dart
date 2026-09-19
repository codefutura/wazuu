import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/moneda.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../home/presentation/providers/tab_seleccionado_provider.dart';
import '../../../transactions/presentation/providers/transacciones_filtro_provider.dart';
import '../providers/tarjetas_consumo_provider.dart';
import '../widgets/cards_skeleton.dart';
import '../widgets/tarjeta_card_widget.dart';

/// Vista de tarjetas — carrusel con consumo del período (sección 9.3 de
/// CLAUDE.md).
class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consumoAsync = ref.watch(tarjetasConsumoProvider);

    return consumoAsync.when(
      loading: () => const CardsSkeleton(),
      error: (error, stackTrace) =>
          Center(child: Text('No se pudieron cargar tus tarjetas: $error')),
      data: (data) {
        if (data.consumos.isEmpty) {
          return const EmptyState(
            icon: Icons.credit_card_outlined,
            title: 'Aún no tienes tarjetas registradas',
            message:
                'Cuando agregues una tarjeta, la vas a ver aquí con su '
                'consumo del período.',
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(tarjetasConsumoProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: AppColors.mintLight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total consolidado',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.teal),
                      ),
                      Text(
                        data.consolidadoDop == null
                            ? 'Configura tu tasa de cambio'
                            : MoneyFormatter.format(
                                data.consolidadoDop!,
                                Moneda.dop,
                              ),
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.85),
                  itemCount: data.consumos.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TarjetaCardWidget(
                      consumo: data.consumos[index],
                      onTap: () => _verTransaccionesDeTarjeta(
                        ref,
                        data.consumos[index].tarjeta.id,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Limpia cualquier otro filtro (categoría, fechas) y deja solo esta
  /// tarjeta, para ver todo su historial sin sorpresas — luego salta
  /// a la pestaña de Transacciones.
  void _verTransaccionesDeTarjeta(WidgetRef ref, int tarjetaId) {
    ref.read(transaccionesFiltroControllerProvider.notifier)
      ..limpiar()
      ..establecerTarjeta(tarjetaId);
    ref.read(tabSeleccionadoControllerProvider.notifier).establecer(1);
  }
}

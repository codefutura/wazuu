import 'package:flutter/material.dart';

import '../../../../core/domain/moneda.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/consumo_tarjeta.dart';
import '../../domain/entities/tarjeta.dart';

class TarjetaCardWidget extends StatelessWidget {
  const TarjetaCardWidget({super.key, required this.consumo, this.onTap});

  final ConsumoTarjeta consumo;

  /// Sección 9.3 de CLAUDE.md — tocar la tarjeta lleva a sus
  /// transacciones.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tarjeta = consumo.tarjeta;
    final textTheme = Theme.of(context).textTheme;
    final progreso = consumo.progresoLimite;

    return Card(
      color: AppColors.teal,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    tarjeta.tipo == TipoTarjeta.credito
                        ? Icons.credit_card
                        : Icons.payments_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tarjeta.apodo,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                '•••• ${tarjeta.ultimos4Digitos}',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.mintLight,
                ),
              ),
              Text(
                tarjeta.nombreBanco,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.mintLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                'Consumo del período',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.mintLight,
                ),
              ),
              Text(
                MoneyFormatter.format(consumo.consumoDop, Moneda.dop),
                style: textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              if (consumo.consumoUsd != 0)
                Text(
                  '+ ${MoneyFormatter.format(consumo.consumoUsd, Moneda.usd)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.mintLight,
                  ),
                ),
              if (progreso != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progreso,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    color: progreso >= 1
                        ? AppColors.coral
                        : AppColors.mintLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progreso * 100).toStringAsFixed(0)}% del límite',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.mintLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

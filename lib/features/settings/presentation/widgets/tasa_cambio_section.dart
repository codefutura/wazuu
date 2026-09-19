import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/bcrd_exchange_rate_provider.dart';
import '../../domain/entities/tasa_bcrd.dart';
import '../providers/tasa_cambio_provider.dart';

class TasaCambioSection extends ConsumerStatefulWidget {
  const TasaCambioSection({super.key});

  @override
  ConsumerState<TasaCambioSection> createState() => _TasaCambioSectionState();
}

class _TasaCambioSectionState extends ConsumerState<TasaCambioSection> {
  final _controller = TextEditingController();
  bool _guardando = false;
  bool _consultandoBancoCentral = false;
  bool _inicializado = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _actualizarDesdeBancoCentral() async {
    setState(() => _consultandoBancoCentral = true);
    try {
      final dataSource = ref.read(bcrdExchangeRateDataSourceProvider);
      final tasa = await dataSource.obtenerTasaActual();
      _controller.text = tasa.venta.toStringAsFixed(4);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tasa de venta del Banco Central (${_formatoFecha(tasa.fecha)}): '
            'revisa y toca "Guardar" para confirmarla.',
          ),
        ),
      );
    } on BcrdExchangeRateException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _consultandoBancoCentral = false);
    }
  }

  String _formatoFecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

  Future<void> _guardar() async {
    final texto = _controller.text.trim().replaceAll(',', '.');
    final tasa = double.tryParse(texto);
    if (tasa == null || tasa <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa una tasa válida')));
      return;
    }
    setState(() => _guardando = true);
    try {
      await ref.read(tasaCambioControllerProvider.notifier).establecer(tasa);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tasa de cambio actualizada')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasaAsync = ref.watch(tasaCambioControllerProvider);

    tasaAsync.whenData((tasa) {
      if (!_inicializado && tasa != null) {
        _controller.text = tasa.toStringAsFixed(2);
        _inicializado = true;
      }
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasa de cambio (RD\$ por US\$1)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Se usa para consolidar tus montos en dólares en el resumen, '
              'las tarjetas y los presupuestos.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      prefixText: 'RD\$ ',
                      hintText: 'Ej. 60.00',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _consultandoBancoCentral
                    ? null
                    : _actualizarDesdeBancoCentral,
                icon: _consultandoBancoCentral
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync, size: 18),
                label: Text(
                  _consultandoBancoCentral
                      ? 'Consultando…'
                      : 'Usar tasa del Banco Central',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

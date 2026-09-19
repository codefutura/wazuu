import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../banks/data/providers/banks_repository_provider.dart';
import '../../../home/presentation/providers/resumen_mensual_provider.dart';
import '../../../transactions/data/providers/transacciones_repository_provider.dart';
import '../../../transactions/presentation/providers/transacciones_filtro_provider.dart';
import '../../data/providers/tarjetas_repository_provider.dart';
import '../../domain/entities/tarjeta.dart';
import '../providers/lista_tarjetas_provider.dart';
import '../providers/tarjetas_consumo_provider.dart';

/// Crear o editar una tarjeta (sección 9.6 de CLAUDE.md — "gestión de
/// tarjetas"). Al editar, el tipo/últimos 4 dígitos/banco no cambian —
/// solo el apodo y el límite, que son los únicos que tiene sentido
/// corregir después de crearla.
class CrearEditarTarjetaSheet extends ConsumerStatefulWidget {
  const CrearEditarTarjetaSheet({super.key, this.tarjetaExistente});

  final Tarjeta? tarjetaExistente;

  @override
  ConsumerState<CrearEditarTarjetaSheet> createState() =>
      _CrearEditarTarjetaSheetState();
}

class _CrearEditarTarjetaSheetState
    extends ConsumerState<CrearEditarTarjetaSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _apodoController = TextEditingController(
    text: widget.tarjetaExistente?.apodo ?? '',
  );
  late final _ultimos4Controller = TextEditingController(
    text: widget.tarjetaExistente?.ultimos4Digitos ?? '',
  );
  late final _limiteController = TextEditingController(
    text: widget.tarjetaExistente?.limiteCredito?.toStringAsFixed(2) ?? '',
  );
  late TipoTarjeta _tipo = widget.tarjetaExistente?.tipo ?? TipoTarjeta.debito;
  late int? _bancoId = widget.tarjetaExistente?.bancoId;
  bool _guardando = false;

  bool get _esEdicion => widget.tarjetaExistente != null;

  @override
  void dispose() {
    _apodoController.dispose();
    _ultimos4Controller.dispose();
    _limiteController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_esEdicion && _bancoId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Elige un banco')));
      return;
    }

    final limiteTexto = _limiteController.text.trim();
    final limite = _tipo == TipoTarjeta.credito && limiteTexto.isNotEmpty
        ? double.tryParse(limiteTexto.replaceAll(',', '.'))
        : null;

    setState(() => _guardando = true);
    try {
      final repo = await ref.read(tarjetasRepositoryProvider.future);
      int? transaccionesVinculadas;
      if (_esEdicion) {
        await repo.actualizar(
          id: widget.tarjetaExistente!.id,
          apodo: _apodoController.text.trim(),
          limiteCredito: limite,
        );
      } else {
        final ultimos4 = _ultimos4Controller.text.trim();
        await repo.crear(
          apodo: _apodoController.text.trim(),
          ultimos4Digitos: ultimos4,
          tipo: _tipo,
          bancoId: _bancoId!,
          limiteCredito: limite,
        );

        // Correos sincronizados antes de que esta tarjeta existiera
        // quedaron con `tarjeta_id` nulo — vincularlos ahora en vez de
        // dejarlos huérfanos para siempre.
        final tarjetaCreada = await repo.obtenerPorUltimos4Digitos(
          bancoId: _bancoId!,
          ultimos4Digitos: ultimos4,
        );
        if (tarjetaCreada != null) {
          final transaccionesRepo = await ref.read(
            transaccionesRepositoryProvider.future,
          );
          transaccionesVinculadas = await transaccionesRepo
              .reasignarTarjetaHuerfanas(
                bancoId: _bancoId!,
                ultimos4Digitos: ultimos4,
                tarjetaId: tarjetaCreada.id,
              );
        }
      }

      ref.invalidate(tarjetasConsumoProvider);
      ref.invalidate(listaTarjetasProvider);
      if ((transaccionesVinculadas ?? 0) > 0) {
        ref.invalidate(transaccionesFiltradasProvider);
        ref.invalidate(resumenMensualProvider);
      }

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      if ((transaccionesVinculadas ?? 0) > 0) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '$transaccionesVinculadas transacción(es) anterior(es) '
              'vinculada(s) a esta tarjeta.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _esEdicion ? 'Editar tarjeta' : 'Nueva tarjeta',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apodoController,
                decoration: const InputDecoration(labelText: 'Apodo'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ingresa un apodo'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ultimos4Controller,
                enabled: !_esEdicion,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Últimos 4 dígitos',
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.length != 4 || int.tryParse(trimmed) == null) {
                    return 'Ingresa 4 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              SegmentedButton<TipoTarjeta>(
                segments: const [
                  ButtonSegment(
                    value: TipoTarjeta.debito,
                    label: Text('Débito'),
                  ),
                  ButtonSegment(
                    value: TipoTarjeta.credito,
                    label: Text('Crédito'),
                  ),
                ],
                selected: {_tipo},
                onSelectionChanged: _esEdicion
                    ? null
                    : (seleccion) => setState(() => _tipo = seleccion.first),
              ),
              const SizedBox(height: 16),
              if (!_esEdicion)
                Consumer(
                  builder: (context, ref, _) {
                    final bancosAsync = ref.watch(bancosConectadosProvider);
                    return bancosAsync.when(
                      data: (bancos) => DropdownButtonFormField<int>(
                        initialValue: _bancoId,
                        decoration: const InputDecoration(labelText: 'Banco'),
                        items: [
                          for (final banco in bancos)
                            DropdownMenuItem(
                              value: banco.id,
                              child: Text(banco.nombreBanco),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _bancoId = value),
                        validator: (value) =>
                            value == null ? 'Elige un banco' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (error, stackTrace) =>
                          Text('No se pudieron cargar tus bancos: $error'),
                    );
                  },
                ),
              if (_tipo == TipoTarjeta.credito) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _limiteController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Límite de crédito (opcional, RD\$)',
                    prefixText: 'RD\$ ',
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_esEdicion ? 'Guardar cambios' : 'Crear tarjeta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

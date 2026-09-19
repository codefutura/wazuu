import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../budgets/presentation/providers/presupuestos_provider.dart';
import '../../../cards/presentation/providers/tarjetas_consumo_provider.dart';
import '../../../home/presentation/providers/resumen_mensual_provider.dart';
import '../../data/providers/usuario_settings_repository_provider.dart';

part 'tasa_cambio_provider.g.dart';

/// Tasa de cambio manual (sección 9.6 de CLAUDE.md). Al cambiarla,
/// invalida los resúmenes que la usan para consolidar DOP/USD — si no,
/// seguirían mostrando el estado "sin tasa configurada" hasta que algo
/// más los recalculara.
@riverpod
class TasaCambioController extends _$TasaCambioController {
  @override
  Future<double?> build() async {
    final repo = await ref.watch(usuarioSettingsRepositoryProvider.future);
    return repo.obtenerTasaCambioReferencia();
  }

  Future<void> establecer(double tasa) async {
    final repo = await ref.read(usuarioSettingsRepositoryProvider.future);
    await repo.establecerTasaCambioReferencia(tasa);
    state = AsyncData(tasa);
    ref.invalidate(resumenMensualProvider);
    ref.invalidate(tarjetasConsumoProvider);
    ref.invalidate(presupuestosConProgresoProvider);
  }
}

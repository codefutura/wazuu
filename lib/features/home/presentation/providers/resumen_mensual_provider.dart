import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/data/providers/usuario_settings_repository_provider.dart';
import '../../../transactions/data/providers/transacciones_repository_provider.dart';
import '../../domain/entities/resumen_mensual.dart';
import '../../domain/resumen_mensual_calculator.dart';

part 'resumen_mensual_provider.g.dart';

typedef ResumenMensualData = ({ResumenMensual resumen, bool hayTransacciones});

/// Rango de la gráfica de tendencia en la pantalla de inicio —
/// controlable por el usuario (sección 9.2 de CLAUDE.md: "se requiere
/// poder manipular los filtros" de la gráfica).
@riverpod
class RangoTendenciaController extends _$RangoTendenciaController {
  @override
  int build() => 6;

  void establecer(int meses) => state = meses;
}

@riverpod
Future<ResumenMensualData> resumenMensual(Ref ref) async {
  final transaccionesRepo = await ref.watch(
    transaccionesRepositoryProvider.future,
  );
  final settingsRepo = await ref.watch(
    usuarioSettingsRepositoryProvider.future,
  );
  final mesesTendencia = ref.watch(rangoTendenciaControllerProvider);

  final ahora = DateTime.now();
  final mesObjetivo = DateTime(ahora.year, ahora.month);
  final desde = DateTime(
    mesObjetivo.year,
    mesObjetivo.month - (mesesTendencia - 1),
  );

  final transacciones = await transaccionesRepo.obtener(desde: desde);
  final tasa = await settingsRepo.obtenerTasaCambioReferencia();

  final resumen = const ResumenMensualCalculator().calcular(
    transacciones: transacciones,
    mesObjetivo: mesObjetivo,
    tasaCambioReferencia: tasa,
    mesesTendencia: mesesTendencia,
  );

  return (resumen: resumen, hayTransacciones: transacciones.isNotEmpty);
}

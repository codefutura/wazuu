import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/data/providers/usuario_settings_repository_provider.dart';
import '../../../transactions/data/providers/transacciones_repository_provider.dart';
import '../../data/providers/tarjetas_repository_provider.dart';
import '../../domain/consumo_tarjetas_calculator.dart';
import '../../domain/entities/consumo_tarjeta.dart';

part 'tarjetas_consumo_provider.g.dart';

typedef TarjetasConsumoData = ({
  List<ConsumoTarjeta> consumos,
  double? consolidadoDop,
});

@riverpod
Future<TarjetasConsumoData> tarjetasConsumo(Ref ref) async {
  final tarjetasRepo = await ref.watch(tarjetasRepositoryProvider.future);
  final transaccionesRepo = await ref.watch(
    transaccionesRepositoryProvider.future,
  );
  final settingsRepo = await ref.watch(
    usuarioSettingsRepositoryProvider.future,
  );

  final ahora = DateTime.now();
  final inicioMes = DateTime(ahora.year, ahora.month);

  final tarjetas = await tarjetasRepo.obtenerTodas();
  final transacciones = await transaccionesRepo.obtener(desde: inicioMes);
  final tasa = await settingsRepo.obtenerTasaCambioReferencia();

  const calculator = ConsumoTarjetasCalculator();
  final consumos = calculator.calcular(
    tarjetas: tarjetas,
    transaccionesDelPeriodo: transacciones,
  );
  final consolidado = calculator.consolidadoDop(consumos, tasa);

  return (consumos: consumos, consolidadoDop: consolidado);
}

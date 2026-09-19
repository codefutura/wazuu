import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/tarjetas_repository_provider.dart';
import '../../domain/entities/tarjeta.dart';

part 'lista_tarjetas_provider.g.dart';

/// Lista simple de tarjetas — usada por Ajustes para gestionarlas
/// (crear/editar/eliminar), sin el cálculo de consumo que trae
/// `tarjetasConsumoProvider`.
@riverpod
Future<List<Tarjeta>> listaTarjetas(Ref ref) async {
  final repo = await ref.watch(tarjetasRepositoryProvider.future);
  return repo.obtenerTodas();
}
